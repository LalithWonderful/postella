-- Postella — Migration initiale (lot 3)
--
-- À exécuter via Supabase Dashboard → SQL Editor → New query → Run.
-- Idempotent : peut être relancé sans casser un état existant (DROP/CREATE IF
-- EXISTS partout où c'est pertinent), à condition de ne pas avoir de données
-- réelles à conserver.

-- =====================================================================
-- Extensions
-- =====================================================================
create extension if not exists "pgcrypto";

-- =====================================================================
-- TABLE: profiles
-- =====================================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  plan text not null default 'free' check (plan in ('free', 'premium')),
  premium_trial_used boolean not null default false,
  created_ads_count integer not null default 0,
  created_at timestamptz not null default now()
);

comment on table public.profiles is 'Profil utilisateur Postella. 1-1 avec auth.users.';

-- Trigger : créer une ligne profiles automatiquement à chaque signup.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email)
  values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =====================================================================
-- TABLE: ads
-- =====================================================================
create table if not exists public.ads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id text not null,
  subcategory text,
  title text,
  description text,
  suggested_price numeric(12, 2),
  condition text,
  photos text[] not null default '{}',
  details jsonb not null default '{}'::jsonb,
  status text not null default 'draft' check (status in ('draft', 'generated', 'saved')),
  generator text not null default 'none' check (generator in ('none', 'gemini', 'openai')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ads_user_id_created_at_idx
  on public.ads (user_id, created_at desc);

comment on table public.ads is 'Annonces créées par les utilisateurs.';

-- Trigger : touch updated_at à chaque update.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists ads_touch_updated_at on public.ads;
create trigger ads_touch_updated_at
  before update on public.ads
  for each row execute function public.touch_updated_at();

-- =====================================================================
-- TABLE: quotas
-- =====================================================================
create table if not exists public.quotas (
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  free_generations_used integer not null default 0,
  premium_generations_used integer not null default 0,
  primary key (user_id, date)
);

comment on table public.quotas is 'Compteur journalier de générations par utilisateur.';

-- =====================================================================
-- RLS
-- =====================================================================
alter table public.profiles enable row level security;
alter table public.ads enable row level security;
alter table public.quotas enable row level security;

-- profiles : un user voit/modifie uniquement son propre profil.
drop policy if exists "profiles select own" on public.profiles;
create policy "profiles select own"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Pas de policy INSERT/DELETE côté client : insert via trigger, delete cascade
-- via auth.users.

-- ads : CRUD complet sur ses propres lignes.
drop policy if exists "ads select own" on public.ads;
create policy "ads select own"
  on public.ads for select
  using (auth.uid() = user_id);

drop policy if exists "ads insert own" on public.ads;
create policy "ads insert own"
  on public.ads for insert
  with check (auth.uid() = user_id);

drop policy if exists "ads update own" on public.ads;
create policy "ads update own"
  on public.ads for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "ads delete own" on public.ads;
create policy "ads delete own"
  on public.ads for delete
  using (auth.uid() = user_id);

-- quotas : lecture seule côté client. L'écriture passe exclusivement par la
-- RPC consume_quota (security definer).
drop policy if exists "quotas select own" on public.quotas;
create policy "quotas select own"
  on public.quotas for select
  using (auth.uid() = user_id);

-- =====================================================================
-- RPC: consume_quota
-- =====================================================================
-- Décide et incrémente atomiquement le compteur du jour pour l'utilisateur
-- courant. Source de vérité côté serveur — le client ne fait que lire l'état
-- via select sur quotas et anticiper via QuotaPolicy.
--
-- Paramètres :
--   p_mode : 'free' (Gemini) ou 'premium' (OpenAI)
--
-- Retour : json
--   {
--     "allowed": bool,
--     "reason": text,            -- enum RefusalReason côté Dart
--     "suggested_action": text,  -- enum SuggestedAction côté Dart
--     "consumes_trial": bool
--   }
--
-- Limites — alignées avec lib/domain/quota_limits.dart :
--   free plan, free gen     : 2 / jour
--   free plan, premium gen  : 1 trial à vie
--   premium plan, free gen  : 15 / jour
--   premium plan, prem gen  : 5 / jour
create or replace function public.consume_quota(p_mode text)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_today date := (now() at time zone 'utc')::date;
  v_plan text;
  v_trial_used boolean;
  v_free_used integer;
  v_premium_used integer;
  v_limit_free_text constant integer := 2;
  v_limit_premium_text constant integer := 15;
  v_limit_premium_image constant integer := 5;
begin
  v_user_id := auth.uid();
  if v_user_id is null then
    return json_build_object(
      'allowed', false,
      'reason', 'premiumRequiresUpgrade',
      'suggested_action', 'upgradeToPremium',
      'consumes_trial', false
    );
  end if;

  if p_mode not in ('free', 'premium') then
    raise exception 'invalid mode: %', p_mode using errcode = '22023';
  end if;

  -- Charger le profil (lock pour éviter les races sur premium_trial_used).
  select plan, premium_trial_used
    into v_plan, v_trial_used
    from public.profiles
    where id = v_user_id
    for update;

  if v_plan is null then
    raise exception 'profile not found for user %', v_user_id;
  end if;

  -- S'assurer que la ligne quotas du jour existe et la verrouiller.
  insert into public.quotas (user_id, date)
    values (v_user_id, v_today)
    on conflict (user_id, date) do nothing;

  select free_generations_used, premium_generations_used
    into v_free_used, v_premium_used
    from public.quotas
    where user_id = v_user_id and date = v_today
    for update;

  -- =================================================================
  -- Mode FREE (Gemini)
  -- =================================================================
  if p_mode = 'free' then
    if v_plan = 'free' then
      if v_free_used < v_limit_free_text then
        update public.quotas
          set free_generations_used = free_generations_used + 1
          where user_id = v_user_id and date = v_today;
        return json_build_object(
          'allowed', true,
          'reason', 'none',
          'suggested_action', 'proceed',
          'consumes_trial', false
        );
      end if;

      if not v_trial_used then
        return json_build_object(
          'allowed', false,
          'reason', 'freeDailyExhausted',
          'suggested_action', 'useTrial',
          'consumes_trial', false
        );
      end if;

      return json_build_object(
        'allowed', false,
        'reason', 'freeDailyExhausted',
        'suggested_action', 'upgradeToPremium',
        'consumes_trial', false
      );
    else
      -- plan premium
      if v_free_used < v_limit_premium_text then
        update public.quotas
          set free_generations_used = free_generations_used + 1
          where user_id = v_user_id and date = v_today;
        return json_build_object(
          'allowed', true,
          'reason', 'none',
          'suggested_action', 'proceed',
          'consumes_trial', false
        );
      end if;
      return json_build_object(
        'allowed', false,
        'reason', 'premiumDailyTextExhausted',
        'suggested_action', 'comeBackTomorrow',
        'consumes_trial', false
      );
    end if;
  end if;

  -- =================================================================
  -- Mode PREMIUM (OpenAI)
  -- =================================================================
  if v_plan = 'free' then
    if not v_trial_used then
      -- Consomme le trial : marquer le profil + incrémenter le compteur.
      update public.profiles
        set premium_trial_used = true
        where id = v_user_id;
      update public.quotas
        set premium_generations_used = premium_generations_used + 1
        where user_id = v_user_id and date = v_today;
      return json_build_object(
        'allowed', true,
        'reason', 'none',
        'suggested_action', 'proceed',
        'consumes_trial', true
      );
    end if;
    return json_build_object(
      'allowed', false,
      'reason', 'premiumRequiresUpgrade',
      'suggested_action', 'upgradeToPremium',
      'consumes_trial', false
    );
  end if;

  -- plan premium, gen premium
  if v_premium_used < v_limit_premium_image then
    update public.quotas
      set premium_generations_used = premium_generations_used + 1
      where user_id = v_user_id and date = v_today;
    return json_build_object(
      'allowed', true,
      'reason', 'none',
      'suggested_action', 'proceed',
      'consumes_trial', false
    );
  end if;

  return json_build_object(
    'allowed', false,
    'reason', 'premiumDailyImageExhausted',
    'suggested_action', 'comeBackTomorrow',
    'consumes_trial', false
  );
end;
$$;

revoke all on function public.consume_quota(text) from public;
grant execute on function public.consume_quota(text) to authenticated;

-- =====================================================================
-- STORAGE bucket: ad-photos (privé)
-- =====================================================================
-- Bucket privé : un utilisateur peut uploader/lire/supprimer uniquement les
-- fichiers dont le chemin commence par son user_id.
insert into storage.buckets (id, name, public)
  values ('ad-photos', 'ad-photos', false)
  on conflict (id) do nothing;

drop policy if exists "ad-photos select own" on storage.objects;
create policy "ad-photos select own"
  on storage.objects for select
  using (
    bucket_id = 'ad-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "ad-photos insert own" on storage.objects;
create policy "ad-photos insert own"
  on storage.objects for insert
  with check (
    bucket_id = 'ad-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "ad-photos delete own" on storage.objects;
create policy "ad-photos delete own"
  on storage.objects for delete
  using (
    bucket_id = 'ad-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
