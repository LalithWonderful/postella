import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth_controller.dart';
import '../router.dart';
import '../widgets/primary_button.dart';
import 'auth_form_layout.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
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
    await controller.signUp(
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
      title: 'Créer un compte',
      subtitle: 'Pour sauvegarder vos annonces et suivre vos quotas.',
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
          autofillHints: const [AutofillHints.newPassword],
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mot de passe',
            helperText: 'Au moins 6 caractères',
          ),
          validator: validatePassword,
          onFieldSubmitted: (_) => _submit(),
        ),
      ],
      primaryAction: PrimaryButton(
        label: isLoading ? 'Création…' : 'Créer mon compte',
        onPressed: isLoading ? null : _submit,
      ),
      secondaryAction: TextButton(
        onPressed: isLoading ? null : () => context.go(AppRoutes.signIn),
        child: const Text('J\'ai déjà un compte'),
      ),
    );
  }
}
