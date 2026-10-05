import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../auth/application/auth_providers.dart';
import '../../card/application/card_providers.dart';
import '../data/platform_nfc_service.dart';
import '../domain/nfc_service.dart';

final nfcServiceProvider = Provider<NfcService>((ref) => PlatformNfcService());

/// Keeps the link that "Always on" tap to share serves while the app is closed
/// in step with the card: only a public card of the signed-in user is shared.
/// Watched by the app root.
final nfcShareLinkSyncProvider = Provider<void>((ref) {
  final signedIn =
      !ref.watch(authRequiredProvider) ||
      ref.watch(currentUserIdProvider) != null;
  final card = ref.watch(myCardProvider);
  if (card.isLoading) return;

  final value = card.value;
  final url = signedIn && value != null && value.isPublic
      ? AppConfig.profileUrl(value.slug)
      : null;
  ref.read(nfcServiceProvider).saveShareLink(url).catchError((Object _) {});
});
