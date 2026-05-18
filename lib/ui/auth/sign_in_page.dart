import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth_controller.dart';
import '../router.dart';
import '../widgets/primary_button.dart';
import 'auth_form_layout.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(authControllerProvider.notifier);
    await controller.signIn(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state is AuthOperationSuccess) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state is AuthOperationLoading;

    return AuthFormLayout(
      title: 'Connexion',
      subtitle: 'Retrouvez vos annonces.',
      formKey: _formKey,
      errorMessage: state is AuthOperationFailure ? state.message : null,
      fields: [
        TextFormField(
          controller: _emailCtrl,
          enabled: !isLoading,
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: validateEmail,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _passwordCtrl,
          enabled: !isLoading,
          autofillHints: const [AutofillHints.password],
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mot de passe'),
          validator: validatePassword,
          onFieldSubmitted: (_) => _submit(),
        ),
      ],
      primaryAction: PrimaryButton(
        label: isLoading ? 'Connexion…' : 'Se connecter',
        onPressed: isLoading ? null : _submit,
      ),
      secondaryAction: TextButton(
        onPressed: isLoading ? null : () => context.go(AppRoutes.signUp),
        child: const Text('Créer un compte'),
      ),
    );
  }
}
