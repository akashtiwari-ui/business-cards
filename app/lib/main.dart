import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();

  // The app is local-first; Supabase is only connected when configured.
  if (AppConfig.hasSupabase) {
    await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabasePublishableKey);
  }

  runApp(const ProviderScope(child: BCardApp()));
}

/// Bundled fonts are SIL OFL; list them on the licences page.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (font, file) in [('Inter', 'OFL-Inter.txt'), ('Plus Jakarta Sans', 'OFL-PlusJakartaSans.txt')]) {
      yield LicenseEntryWithLineBreaks([font], await rootBundle.loadString('assets/fonts/$file'));
    }
  });
}
