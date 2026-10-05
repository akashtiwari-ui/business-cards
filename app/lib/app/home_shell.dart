import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Index of the visible bottom tab, so screens kept alive in the background
/// (the scanner's camera) can pause themselves.
class CurrentTab extends Notifier<int> {
  @override
  int build() => 0;

  void show(int index) {
    if (state != index) state = index;
  }
}

final currentTabProvider = NotifierProvider<CurrentTab, int>(CurrentTab.new);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = navigationShell.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(currentTabProvider.notifier).show(index));

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => navigationShell.goBranch(i, initialLocation: i == index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge), label: 'My Card'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Contacts'),
        ],
      ),
    );
  }
}
