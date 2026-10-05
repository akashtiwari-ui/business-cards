import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../../core/db/app_database.dart';
import '../../auth/application/auth_providers.dart';
import '../data/local_card_repository.dart';
import '../data/supabase_card_remote.dart';
import '../domain/business_card.dart';
import '../domain/card_remote_data_source.dart';
import '../domain/card_repository.dart';
import 'card_sync.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authUserProvider.select((user) => user.value?.id)),
);

/// Cards on this phone, scoped to the signed-in user.
final localCardRepositoryProvider = Provider<LocalCardRepository>(
  (ref) => LocalCardRepository(
    ref.watch(appDatabaseProvider),
    ownerId: ref.watch(currentUserIdProvider),
  ),
);

final cardRepositoryProvider = Provider<CardRepository>(
  (ref) => ref.watch(localCardRepositoryProvider),
);

/// Null in the offline-only build.
final cardRemoteProvider = Provider<CardRemoteDataSource?>(
  (ref) => ref.watch(authRequiredProvider) ? SupabaseCardRemote(Supabase.instance.client) : null,
);

/// Runs while a user is signed in; watched by the app root.
final cardSyncProvider = Provider<CardSync?>((ref) {
  final remote = ref.watch(cardRemoteProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (remote == null || userId == null) return null;

  final sync = CardSync(local: ref.watch(localCardRepositoryProvider), remote: remote, userId: userId)
    ..start();
  final lifecycle = AppLifecycleListener(onResume: sync.syncNow);
  ref.onDispose(() {
    lifecycle.dispose();
    sync.dispose();
  });
  return sync;
});

final myCardProvider = StreamProvider<BusinessCard?>(
  (ref) => ref.watch(cardRepositoryProvider).watchMyCard(),
);
