import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/platform_nfc_service.dart';
import '../domain/nfc_service.dart';

final nfcServiceProvider = Provider<NfcService>((ref) => PlatformNfcService());
