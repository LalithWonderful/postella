import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ad_detail/ad_detail_page.dart';
import 'ads_list/ads_list_page.dart';
import 'auth/sign_in_page.dart';
import 'auth/sign_up_page.dart';
import 'create_ad/category_picker_page.dart';
import 'create_ad/details_page.dart';
import 'create_ad/generating_page.dart';
import 'create_ad/photos_page.dart';
import 'create_ad/result_page.dart';
import 'home/home_shell.dart';
import 'onboarding/onboarding_page.dart';
import 'quota/quota_page.dart';
import 'settings/settings_page.dart';
import 'splash/splash_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';

  static const home = '/home';
  static const quota = '/quota';
  static const settings = '/settings';

  static const adDetail = '/ads/:id';

  static const createCategory = '/create';
  static const createPhotos = '/create/photos';
  static const createDetails = '/create/details';
  static const createGenerating = '/create/generating';
  static const createResult = '/create/result';
}

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (_, _) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, _) => const SignUpPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, _) => const AdsListPage(),
          ),
          GoRoute(
            path: AppRoutes.quota,
            builder: (_, _) => const QuotaPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, _) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.adDetail,
        builder: (_, state) => AdDetailPage(adId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.createCategory,
        builder: (_, _) => const CategoryPickerPage(),
      ),
      GoRoute(
        path: AppRoutes.createPhotos,
        builder: (_, _) => const PhotosPage(),
      ),
      GoRoute(
        path: AppRoutes.createDetails,
        builder: (_, _) => const DetailsPage(),
      ),
      GoRoute(
        path: AppRoutes.createGenerating,
        builder: (_, _) => const GeneratingPage(),
      ),
      GoRoute(
        path: AppRoutes.createResult,
        builder: (_, _) => const ResultPage(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(title: const Text('Page introuvable')),
      body: Center(child: Text('Route inconnue : ${state.uri}')),
    ),
  );
}
