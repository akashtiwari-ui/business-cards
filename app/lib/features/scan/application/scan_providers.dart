import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../../core/config/app_config.dart';
import '../../auth/application/auth_providers.dart';
import '../../card/application/card_providers.dart';
import '../../contacts/application/contact_providers.dart';
import '../data/supabase_public_profile_source.dart';
import '../domain/public_profile_source.dart';
import 'scan_service.dart';

/// Null in the offline-only build.
final publicProfileSourceProvider = Provider<PublicProfileSource?>(
  (ref) => ref.watch(authRequiredProvider) ? SupabasePublicProfileSource(Supabase.instance.client) : null,
);

final scanServiceProvider = Provider<ScanService>(
  (ref) => ScanService(
    contacts: ref.watch(contactRepositoryProvider),
    profiles: ref.watch(publicProfileSourceProvider),
    profileBaseUrl: AppConfig.profileBaseUrl,
    ownSlug: ref.watch(myCardProvider.select((card) => card.value?.slug)),
  ),
);

/// Completes offline scans at launch and whenever the app comes back to the
/// foreground (PRD 4.4). Watched by the app root.
final pendingScanResolverProvider = Provider<void>((ref) {
  if (ref.watch(currentUserIdProvider) == null) return;
  final service = ref.watch(scanServiceProvider);
  service.resolvePending();
  final lifecycle = AppLifecycleListener(onResume: service.resolvePending);
  ref.onDispose(lifecycle.dispose);
});
