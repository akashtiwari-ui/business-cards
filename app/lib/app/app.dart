import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/card/application/card_providers.dart';
import 'router.dart';
import 'theme.dart';

class BCardApp extends ConsumerWidget {
  const BCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the card syncing for as long as someone is signed in.
    ref.watch(cardSyncProvider);
    return MaterialApp.router(
      title: 'B Card',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
