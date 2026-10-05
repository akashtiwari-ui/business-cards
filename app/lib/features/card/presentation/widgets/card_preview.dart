import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../domain/business_card.dart';

/// The digital card on its Midnight Navy surface (PRD 4.2).
/// With [publicView], fields the owner hid are left out.
class CardPreview extends StatelessWidget {
  const CardPreview({super.key, required this.card, this.publicView = false});

  final BusinessCard card;
  final bool publicView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = StatusColors.of(context);
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.brandCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.avatarFor(card.name),
                  child: Text(
                    card.initials,
                    style: theme.textTheme.titleLarge?.copyWith(color: AppColors.ink),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        style: theme.textTheme.titleLarge?.copyWith(color: status.onBrandCard),
                      ),
                      if (card.headline.isNotEmpty)
                        Text(
                          card.headline,
                          style: theme.textTheme.bodyMedium?.copyWith(color: status.onBrandCardMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (card.bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(card.bio, style: theme.textTheme.bodyMedium?.copyWith(color: status.onBrandCard)),
            ],
            if (rows.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(color: status.onBrandCard.withValues(alpha: 0.15)),
              const SizedBox(height: 4),
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
    final status = StatusColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: status.onBrandCardMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: status.onBrandCard),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
