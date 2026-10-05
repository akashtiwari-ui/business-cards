import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._auth);

  final GoTrueClient _auth;

  @override
  Stream<AppUser?> watchUser() async* {
    yield _toAppUser(_auth.currentUser);
    yield* _auth.onAuthStateChange.map((state) => _toAppUser(state.session?.user));
  }

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithPassword(email: email.trim(), password: password));

  @override
  Future<SignUpOutcome> signUp({required String email, required String password}) async {
    final response = await _guard(() => _auth.signUp(email: email.trim(), password: password));
    // Supabase hides whether an email is already registered: an existing
    // account comes back as a user with no identities and no session.
    if (response.user?.identities?.isEmpty ?? false) {
      throw const AuthFailure('An account with this email already exists. Sign in instead.');
    }
    return response.session == null ? SignUpOutcome.confirmEmail : SignUpOutcome.signedIn;
  }

  @override
  Future<void> signOut() => _guard(_auth.signOut);

  AppUser? _toAppUser(User? user) =>
      user == null ? null : AppUser(id: user.id, email: user.email ?? '');

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AuthException catch (e) {
      throw AuthFailure(_friendly(e));
    } catch (_) {
      throw const AuthFailure('Could not reach the server. Check your connection and try again.');
    }
  }

  String _friendly(AuthException e) => switch (e.code) {
        'invalid_credentials' => 'Incorrect email or password.',
        'email_not_confirmed' => 'Confirm your email first. Check your inbox for the link.',
        'user_already_exists' => 'An account with this email already exists. Sign in instead.',
        'weak_password' => 'Choose a stronger password (at least 8 characters).',
        'over_email_send_rate_limit' => 'Too many emails sent. Try again in a little while.',
        _ => e.message,
      };
}
