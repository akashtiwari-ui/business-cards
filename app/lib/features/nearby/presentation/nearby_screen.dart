import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../app/widgets/status_pill.dart';
import '../../scan/application/scan_service.dart';
import '../application/nearby_controller.dart';
import '../domain/beacon_id.dart';

/// Beacon mode (Nearby): be visible to, and see, B Card users around you.
/// Bluetooth runs only while this screen is open.
class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Coming back from Bluetooth settings: try again if we were blocked.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        final status = ref.read(nearbyControllerProvider).status;
        if (status == NearbyStatus.bluetoothOff ||
            status == NearbyStatus.permissionDenied) {
          ref.read(nearbyControllerProvider.notifier).retry();
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(nearbyControllerProvider.notifier).start(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _save(NearbyPerson person) async {
    final outcome = await ref
        .read(nearbyControllerProvider.notifier)
        .save(person);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    final message = switch (outcome) {
      ContactSaved() => '${person.profile.name} saved to contacts',
      AlreadySaved() => '${person.profile.name} is already in your contacts',
      SavedOffline() => 'Saved. Details load when you\'re back online.',
      ProfileUnavailable() => 'This profile is no longer available',
      _ => 'Could not save this contact',
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nearbyControllerProvider);
    final controller = ref.read(nearbyControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby')),
      body: switch (state.status) {
        NearbyStatus.idle || NearbyStatus.starting => const Center(
          child: CircularProgressIndicator(),
        ),
        NearbyStatus.bluetoothOff => _Blocked(
          icon: Icons.bluetooth_disabled,
          title: 'Bluetooth is off',
          body: 'Turn on Bluetooth to find B Card users around you.',
          actionLabel: 'Open Bluetooth settings',
          onAction: controller.openSettings,
        ),
        NearbyStatus.permissionDenied => _Blocked(
          icon: Icons.bluetooth_disabled,
          title: 'Allow Nearby devices',
          body:
              'B Card needs the "Nearby devices" permission to find people around you. '
              'It never uses Bluetooth to work out your location.',
          actionLabel: 'Try again',
          onAction: controller.retry,
        ),
        NearbyStatus.unsupported => const _Blocked(
          icon: Icons.bluetooth_disabled,
          title: "This phone can't use Nearby",
          body: 'Share with your QR code or NFC instead.',
        ),
        NearbyStatus.needsAccount => const _Blocked(
          icon: Icons.person_outline,
          title: 'Sign in to use Nearby',
          body: 'Nearby matches people through your B Card account.',
        ),
        NearbyStatus.active => _ActiveList(state: state, onSave: _save),
      },
    );
  }
}

class _ActiveList extends StatelessWidget {
  const _ActiveList({required this.state, required this.onSave});

  final NearbyState state;
  final void Function(NearbyPerson) onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        _VisibilityCard(state: state),
        const SizedBox(height: 24),
        Row(
          children: [
            Text('People nearby', style: theme.textTheme.titleMedium),
            const Spacer(),
            const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          state.lookupFailing
              ? "Can't reach B Card right now. People will appear when you're back online."
              : 'Ask the people you meet to open Nearby in B Card.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (state.people.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.radar,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Looking for B Card users…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          for (final person in state.people) ...[
            _PersonTile(person: person, onSave: () => onSave(person)),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _VisibilityCard extends StatelessWidget {
  const _VisibilityCard({required this.state});

  final NearbyState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, body) = state.visible
        ? (
            'You are visible',
            'B Card users nearby can see your name, title and company and save your card. '
                'Leave this screen to stop.',
          )
        : switch (state.notVisibleReason) {
            NotVisibleReason.noCard => (
              'You are not visible',
              'Create your card to be visible to others.',
            ),
            NotVisibleReason.hidden => (
              'You are not visible',
              'Your profile is hidden. Make it public on My Card to be visible.',
            ),
            NotVisibleReason.cannotAdvertise => (
              'You are not visible',
              "This phone can't broadcast over Bluetooth, but you can still see others.",
            ),
            _ => (
              'You are not visible',
              'Connect to the internet so others can find you.',
            ),
          };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.sensors, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            StatusPill(
              label: state.visible ? 'Beacon on' : 'Beacon off',
              icon: state.visible ? Icons.sensors : Icons.sensors_off,
              tone: state.visible ? PillTone.success : PillTone.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person, required this.onSave});

  final NearbyPerson person;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = person.profile;
    final distance = switch (person.proximity) {
      Proximity.veryClose => 'Very close',
      Proximity.nearby => 'Nearby',
      Proximity.inTheRoom => 'In the room',
    };
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.avatarFor(profile.name),
          child: Text(
            profile.name
                .trim()
                .split(RegExp(r'\s+'))
                .take(2)
                .map((p) => p[0].toUpperCase())
                .join(),
            style: theme.textTheme.labelLarge?.copyWith(color: AppColors.ink),
          ),
        ),
        title: Text(
          profile.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          [
            if (profile.headline.isNotEmpty) profile.headline,
            distance,
          ].join('\n'),
        ),
        isThreeLine: profile.headline.isNotEmpty,
        trailing: person.saved
            ? const StatusPill(
                label: 'Saved',
                icon: Icons.check,
                tone: PillTone.success,
              )
            : FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(minimumSize: const Size(88, 48)),
                child: const Text('Save'),
              ),
      ),
    );
  }
}

class _Blocked extends StatelessWidget {
  const _Blocked({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(icon, size: 36, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
