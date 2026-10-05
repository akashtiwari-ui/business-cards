import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../../core/config/app_config.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';

/// Sign-in is required only when a backend is configured; the offline-only
/// build runs without accounts.
final authRequiredProvider = Provider<bool>((ref) => AppConfig.hasSupabase);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(Supabase.instance.client.auth),
);

final authUserProvider = StreamProvider<AppUser?>((ref) {
  if (!ref.watch(authRequiredProvider)) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchUser();
});
