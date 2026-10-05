import 'package:flutter/material.dart';

import '../theme.dart';

enum PillTone { success, warning, neutral, brand }

/// Fully rounded status chip, e.g. "Public profile · Live" or "Synced".
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.icon, required this.tone, this.onTap, this.tooltip});

  final String label;
  final IconData icon;
  final PillTone tone;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = StatusColors.of(context);
    final (fg, bg) = switch (tone) {
      PillTone.success => (status.success, status.successContainer),
      PillTone.warning => (status.warning, status.warningContainer),
      PillTone.neutral => (scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
      PillTone.brand => (scheme.onPrimaryContainer, scheme.primaryContainer),
    };

    Widget pill = Material(
      color: bg,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: ConstrainedBox(
          // Tappable pills keep the 48 dp target; read-only ones can be compact.
          constraints: BoxConstraints(minHeight: onTap == null ? 32 : 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
    if (tooltip != null) pill = Tooltip(message: tooltip!, child: pill);
    return Semantics(button: onTap != null, child: pill);
  }
}
