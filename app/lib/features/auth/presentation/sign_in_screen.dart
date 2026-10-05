import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../card/domain/card_validators.dart';
import '../application/auth_providers.dart';
import '../domain/auth_repository.dart';

/// Email and password sign-in / sign-up. Navigation after success is handled
/// by the router reacting to the auth state.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isSignUp = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Enter your email' : validateEmail(value);

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Enter your password';
    if (_isSignUp && password.length < 8) return 'Use at least 8 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });

    final repo = ref.read(authRepositoryProvider);
    try {
      if (_isSignUp) {
        final outcome = await repo.signUp(email: _email.text, password: _password.text);
        if (outcome == SignUpOutcome.confirmEmail && mounted) {
          setState(() {
            _isSignUp = false;
            _password.clear();
            _info = 'Account created. Confirm your email from the link we sent to '
                '${_email.text.trim()}, then sign in.';
          });
        }
      } else {
        await repo.signIn(email: _email.text, password: _password.text);
      }
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toggleMode() => setState(() {
        _isSignUp = !_isSignUp;
        _error = null;
        _info = null;
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.badge_outlined, size: 56, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      _isSignUp ? 'Create your account' : 'Welcome back',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'One tap to share who you are; one scan to remember who you met.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    if (_info != null) _Banner(text: _info!, isError: false),
                    if (_error != null) _Banner(text: _error!, isError: true),
                    TextFormField(
                      controller: _email,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      validator: _validatePassword,
                      obscureText: _obscure,
                      autofillHints: [_isSignUp ? AutofillHints.newPassword : AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _busy ? null : _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText: _isSignUp ? 'At least 8 characters' : null,
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isSignUp ? 'Create account' : 'Sign in'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _busy ? null : _toggleMode,
                      child: Text(_isSignUp ? 'Already have an account? Sign in' : 'New to B Card? Create an account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        color: isError ? scheme.errorContainer : scheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(isError ? Icons.error_outline : Icons.mark_email_read_outlined,
                  color: isError ? scheme.onErrorContainer : scheme.onSecondaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(text,
                    style: TextStyle(color: isError ? scheme.onErrorContainer : scheme.onSecondaryContainer)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
