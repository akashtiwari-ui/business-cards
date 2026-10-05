import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/card/presentation/card_editor_screen.dart';
import '../features/card/presentation/my_card_screen.dart';
import '../features/card/presentation/share_card_screen.dart';
import 'home_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever the signed-in user changes.
  final authChanges = ValueNotifier(0);
  ref.listen(authUserProvider, (_, _) => authChanges.value++);
  ref.onDispose(authChanges.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/card',
    refreshListenable: authChanges,
    redirect: (context, state) {
      if (!ref.read(authRequiredProvider)) return null;
      final user = ref.read(authUserProvider);
      if (user.isLoading) return null;
      final atSignIn = state.matchedLocation == '/sign-in';
      if (user.value == null) return atSignIn ? null : '/sign-in';
      return atSignIn ? '/card' : null;
    },
    routes: [
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/card',
              builder: (_, _) => const MyCardScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const CardEditorScreen(),
                ),
                GoRoute(
                  path: 'share',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const ShareCardScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/scan',
              builder: (_, _) => const ComingNextScreen(
                title: 'Scan',
                icon: Icons.qr_code_scanner,
                message: 'Scan a B Card or any vCard QR to save the contact.',
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/contacts',
              builder: (_, _) => const ComingNextScreen(
                title: 'Contacts',
                icon: Icons.people_outline,
                message: 'People you scan will appear here, searchable and offline.',
              ),
            ),
          ]),
        ],
      ),
    ],
  );
});
