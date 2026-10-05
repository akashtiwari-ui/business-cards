import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  const AppUser({required this.id, required this.email});

  final String id;
  final String email;
}

enum SignUpOutcome {
  /// Account created and signed in.
  signedIn,

  /// Account created; the user must confirm their email before signing in.
  confirmEmail,
}

/// A sign-in or sign-up failure with a message safe to show the user.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  /// Emits the current user first, then every change; null when signed out.
  Stream<AppUser?> watchUser();

  Future<void> signIn({required String email, required String password});

  Future<SignUpOutcome> signUp({required String email, required String password});

  Future<void> signOut();
}
