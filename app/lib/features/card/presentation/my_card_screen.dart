import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../application/card_providers.dart';
import '../domain/business_card.dart';
import 'widgets/card_preview.dart';

/// Home screen: the user's card, its public status and main actions (PRD 4.2).
class MyCardScreen extends ConsumerWidget {
  const MyCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = ref.watch(myCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Card'),
        actions: [
          if (card.value != null)
            IconButton(
              tooltip: 'Edit card',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/card/edit'),
            ),
          if (ref.watch(authUserProvider).value case final user?)
            PopupMenuButton<void>(
              tooltip: 'Account',
              icon: const Icon(Icons.account_circle_outlined),
              itemBuilder: (context) => [
                PopupMenuItem(enabled: false, child: Text(user.email)),
                PopupMenuItem(
                  onTap: () => ref.read(authRepositoryProvider).signOut(),
                  child: const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.logout),
                    title: Text('Sign out'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: card.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load your card.\n$error')),
        data: (card) => card == null ? const _EmptyState() : _CardBody(card: card),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.badge_outlined, size: 40, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text('Create your digital card', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'Only your name is required. You can add the rest later.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/card/edit'),
              icon: const Icon(Icons.add),
              label: const Text('Create card'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncStatus extends StatelessWidget {
  const _SyncStatus({required this.pending});

  final bool pending;

  @override
  Widget build(BuildContext context) => StatusPill(
        label: pending ? 'Waiting to sync' : 'Synced',
        icon: pending ? Icons.cloud_upload_outlined : Icons.cloud_done_outlined,
        tone: pending ? PillTone.warning : PillTone.success,
      );
}

class _CardBody extends ConsumerWidget {
  const _CardBody({required this.card});

  final BusinessCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusPill(
              icon: card.isPublic ? Icons.public : Icons.visibility_off_outlined,
              label: card.isPublic ? 'Public profile · Live' : 'Public profile · Hidden',
              tone: card.isPublic ? PillTone.success : PillTone.neutral,
              tooltip: card.isPublic ? 'Hide public profile' : 'Make profile public',
              onTap: () => ref
                  .read(cardRepositoryProvider)
                  .setVisibility(card.id, isPublic: !card.isPublic),
            ),
            if (ref.watch(authRequiredProvider)) _SyncStatus(pending: card.syncPending),
          ],
        ),
        const SizedBox(height: 12),
        CardPreview(card: card),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => context.push('/card/share'),
          icon: const Icon(Icons.qr_code_2),
          label: const Text('Share my card'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showPublicPreview(context),
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('Preview profile'),
        ),
      ],
    );
  }

  void _showPublicPreview(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What visitors see', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (card.isPublic)
                CardPreview(card: card, publicView: true)
              else
                const ListTile(
                  leading: Icon(Icons.visibility_off_outlined),
                  title: Text('Profile unavailable'),
                  subtitle: Text('Your profile is hidden. Visitors see this neutral page.'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
