import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme.dart';
import '../../../app/widgets/status_pill.dart';
import '../../contacts/domain/contact.dart';
import '../application/scan_service.dart';

enum ScanSheetAction { review, viewContacts }

/// "Profile found" and the other scan results (PRD 4.4).
class ScanResultSheet extends StatelessWidget {
  const ScanResultSheet({super.key, required this.outcome});

  final ScanOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    void close([ScanSheetAction? action]) => Navigator.pop(context, action);

    final body = switch (outcome) {
      ContactSaved(:final contact) => _ContactResult(
          contact: contact,
          status: const StatusPill(label: 'Saved to contacts', icon: Icons.check_circle_outline, tone: PillTone.success),
          title: 'Profile found',
          onReview: () => close(ScanSheetAction.review),
          onDone: close,
        ),
      AlreadySaved(:final contact, :final refreshed) => _ContactResult(
          contact: contact,
          status: StatusPill(
            label: refreshed ? 'Already saved · updated' : 'Already in your contacts',
            icon: Icons.people_outline,
            tone: PillTone.brand,
          ),
          title: 'Already in your contacts',
          onReview: () => close(ScanSheetAction.review),
          onDone: close,
        ),
      SavedOffline() => _Message(
          icon: Icons.cloud_off_outlined,
          colour: StatusColors.of(context).warning,
          title: 'Saved offline',
          body: "You're offline, so we saved the code. Their details will appear when you're back online.",
          actions: [
            FilledButton(onPressed: () => close(ScanSheetAction.viewContacts), child: const Text('View contacts')),
            TextButton(onPressed: close, child: const Text('Scan another')),
          ],
        ),
      ProfileUnavailable() => _Message(
          icon: Icons.visibility_off_outlined,
          colour: theme.colorScheme.onSurfaceVariant,
          title: 'Profile unavailable',
          body: 'This card is hidden or no longer exists. Nothing was saved.',
          actions: [FilledButton(onPressed: close, child: const Text('Scan another'))],
        ),
      OwnCardScanned() => _Message(
          icon: Icons.badge_outlined,
          colour: theme.colorScheme.primary,
          title: "That's your own card",
          body: 'Scan someone else\'s card to save them as a contact.',
          actions: [FilledButton(onPressed: close, child: const Text('Scan another'))],
        ),
      NotAContactCode(:final text) => _Message(
          icon: Icons.qr_code_2,
          colour: theme.colorScheme.onSurfaceVariant,
          title: 'Not a contact QR code',
          body: 'This code doesn\'t hold a business card.',
          detail: text,
          actions: [
            FilledButton(onPressed: close, child: const Text('Scan another')),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text));
                close();
              },
              child: const Text('Copy text'),
            ),
          ],
        ),
    };

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: body,
      ),
    );
  }
}

class _ContactResult extends StatelessWidget {
  const _ContactResult({
    required this.contact,
    required this.status,
    required this.title,
    required this.onReview,
    required this.onDone,
  });

  final Contact contact;
  final Widget status;
  final String title;
  final VoidCallback onReview;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StatusColors.of(context).brandCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.avatarFor(contact.name),
                child: Text(contact.initials, style: theme.textTheme.titleMedium?.copyWith(color: AppColors.ink)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name,
                        style: theme.textTheme.titleLarge?.copyWith(color: StatusColors.of(context).onBrandCard)),
                    if (contact.headline.isNotEmpty)
                      Text(contact.headline,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: StatusColors.of(context).onBrandCardMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(child: status),
        const SizedBox(height: 20),
        FilledButton(onPressed: onReview, child: const Text('Review contact')),
        const SizedBox(height: 8),
        TextButton(onPressed: onDone, child: const Text('Scan another')),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.colour,
    required this.title,
    required this.body,
    required this.actions,
    this.detail,
  });

  final IconData icon;
  final Color colour;
  final String title;
  final String body;
  final String? detail;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 56, color: colour),
        const SizedBox(height: 12),
        Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        if (detail != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(detail!, maxLines: 4, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
          ),
        ],
        const SizedBox(height: 20),
        for (final action in actions) ...[action, const SizedBox(height: 8)],
      ],
    );
  }
}
