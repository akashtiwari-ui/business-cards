import 'package:flutter/material.dart';

import '../../domain/business_card.dart';

/// Renders a card the way the public profile shows it (PRD 4.2).
/// With [publicView], fields the owner hid are left out.
class CardPreview extends StatelessWidget {
  const CardPreview({super.key, required this.card, this.publicView = false});

  final BusinessCard card;
  final bool publicView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final showEmail = card.email.isNotEmpty && !(publicView && card.hideEmail);
    final showPhone = card.phone.isNotEmpty && !(publicView && card.hidePhone);

    final rows = [
      if (showEmail) _InfoRow(icon: Icons.mail_outline, text: card.email),
      if (showPhone) _InfoRow(icon: Icons.phone_outlined, text: card.phone),
      if (card.location.isNotEmpty)
        _InfoRow(icon: Icons.location_on_outlined, text: card.location),
      if (card.website.isNotEmpty)
        _InfoRow(icon: Icons.language, text: card.website),
      if (card.linkedin.isNotEmpty)
        _InfoRow(icon: Icons.work_outline, text: card.linkedin),
      for (final link in card.links)
        _InfoRow(icon: Icons.link, text: link.label.isEmpty ? link.url : link.label),
    ];

    return Card(
      elevation: 0,
      color: scheme.primaryContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  child: Text(card.initials, style: theme.textTheme.titleLarge?.copyWith(color: scheme.onPrimary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                      if (card.headline.isNotEmpty)
                        Text(
                          card.headline,
                          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onPrimaryContainer),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (card.bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(card.bio, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onPrimaryContainer)),
            ],
            if (rows.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: scheme.onPrimaryContainer.withValues(alpha: 0.2)),
              ...rows,
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimaryContainer;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: color), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
