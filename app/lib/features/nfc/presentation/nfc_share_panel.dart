import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../app/widgets/status_pill.dart';
import '../application/nfc_providers.dart';
import '../domain/nfc_service.dart';

/// The NFC tab of the Share screen (PRD 4.3). While visible, the phone shares
/// [url] by tap (where supported); a sheet writes [url] to an NFC tag.
class NfcSharePanel extends ConsumerStatefulWidget {
  const NfcSharePanel({super.key, required this.url});

  final String url;

  @override
  ConsumerState<NfcSharePanel> createState() => _NfcSharePanelState();
}

class _NfcSharePanelState extends ConsumerState<NfcSharePanel> {
  late final NfcService _nfc = ref.read(nfcServiceProvider);
  late final AppLifecycleListener _lifecycle;
  NfcSupport? _support;
  bool _canTapShare = false;
  bool _tapSharing = false;
  bool _alwaysOn = false;
  bool _canAddTile = false;

  @override
  void initState() {
    super.initState();
    // Re-check when returning from the NFC settings screen.
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    _refresh();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    if (_tapSharing) _nfc.stopTapToShare();
    super.dispose();
  }

  Future<void> _refresh() async {
    final support = await _nfc.availability();
    final canTapShare =
        support == NfcSupport.enabled && await _nfc.supportsTapToShare();
    final alwaysOn = canTapShare && await _nfc.isAlwaysOn();
    final canAddTile = canTapShare && await _nfc.canAddQuickSettingsTile();
    if (!mounted) return;
    setState(() {
      _support = support;
      _canTapShare = canTapShare;
      _alwaysOn = alwaysOn;
      _canAddTile = canAddTile;
    });
    await _setTapSharing(canTapShare);
  }

  Future<void> _setTapSharing(bool on) async {
    if (on == _tapSharing) return;
    try {
      on ? await _nfc.startTapToShare(widget.url) : await _nfc.stopTapToShare();
      if (mounted) setState(() => _tapSharing = on);
    } catch (_) {
      if (mounted) setState(() => _tapSharing = false);
    }
  }

  Future<void> _setAlwaysOn(bool on) async {
    final result = await _nfc.setAlwaysOn(on);
    if (!mounted) return;
    setState(() => _alwaysOn = result);
    if (on && !result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Make your profile public on My Card to share it by tap.',
          ),
        ),
      );
    }
  }

  Future<void> _openWriteSheet() async {
    // Reading tags and acting as a tag can't run together.
    await _setTapSharing(false);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => WriteTagSheet(url: widget.url, nfc: _nfc),
    );
    if (mounted) await _setTapSharing(_canTapShare);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_support) {
      null => const Center(child: CircularProgressIndicator()),
      NfcSupport.unsupported => const _Notice(
        icon: Icons.nfc,
        title: "This phone doesn't have NFC",
        body: 'Share with the QR code instead.',
      ),
      NfcSupport.disabled => _Notice(
        icon: Icons.nfc,
        title: 'NFC is turned off',
        body: 'Turn on NFC to share your card by tapping.',
        action: FilledButton(
          onPressed: _nfc.openSettings,
          child: const Text('Open NFC settings'),
        ),
      ),
      NfcSupport.enabled => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TapToShareCard(
            available: _canTapShare,
            active: _tapSharing,
            alwaysOn: _alwaysOn,
            onAlwaysOnChanged: _setAlwaysOn,
            onAddTile: _canAddTile ? _nfc.addQuickSettingsTile : null,
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.contactless_outlined,
            title: 'Write to an NFC tag',
            body:
                'Put your card on an NFC sticker, keychain or blank NFC card. '
                'Anyone can tap it to open your profile.',
            action: FilledButton.icon(
              onPressed: _openWriteSheet,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Write to NFC tag'),
            ),
          ),
        ],
      ),
    };
  }
}

class _TapToShareCard extends StatelessWidget {
  const _TapToShareCard({
    required this.available,
    required this.active,
    required this.alwaysOn,
    required this.onAlwaysOnChanged,
    this.onAddTile,
  });

  final bool available;
  final bool active;
  final bool alwaysOn;
  final ValueChanged<bool> onAlwaysOnChanged;
  final VoidCallback? onAddTile;

  @override
  Widget build(BuildContext context) {
    if (!available) {
      return const _ActionCard(
        icon: Icons.tap_and_play,
        title: 'Tap phones to share',
        body:
            "This phone can't share by tapping. Write your card to an NFC tag instead.",
      );
    }
    return _ActionCard(
      icon: Icons.tap_and_play,
      title: 'Tap phones to share',
      body:
          'Hold the back of another phone against yours. Their phone opens your profile, '
          'no app needed.',
      status: StatusPill(
        label: active ? 'Ready to share' : 'Starting…',
        icon: active ? Icons.check_circle_outline : Icons.hourglass_empty,
        tone: active ? PillTone.success : PillTone.neutral,
      ),
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Always on'),
            subtitle: const Text(
              'Share by tap even when B Card is closed, whenever your screen is on.',
            ),
            value: alwaysOn,
            onChanged: onAlwaysOnChanged,
          ),
          if (onAddTile != null)
            OutlinedButton.icon(
              onPressed: onAddTile,
              icon: const Icon(Icons.add_to_home_screen),
              label: const Text('Add to Quick Settings'),
            ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.body,
    this.status,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? status;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  child: Icon(icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (status != null) ...[const SizedBox(height: 12), status!],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

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
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

enum _WriteState { ready, writing, success, failure }

/// Ready → writing → success / failure, as the PRD asks for.
class WriteTagSheet extends StatefulWidget {
  const WriteTagSheet({super.key, required this.url, required this.nfc});

  final String url;
  final NfcService nfc;

  @override
  State<WriteTagSheet> createState() => _WriteTagSheetState();
}

class _WriteTagSheetState extends State<WriteTagSheet> {
  _WriteState _state = _WriteState.ready;
  String? _error;

  @override
  void initState() {
    super.initState();
    _write();
  }

  @override
  void dispose() {
    if (_state == _WriteState.ready || _state == _WriteState.writing) {
      widget.nfc.cancelWrite();
    }
    super.dispose();
  }

  Future<void> _write() async {
    setState(() {
      _state = _WriteState.ready;
      _error = null;
    });
    try {
      await widget.nfc.writeUrl(
        widget.url,
        onTagDetected: () {
          if (mounted) setState(() => _state = _WriteState.writing);
        },
      );
      HapticFeedback.mediumImpact();
      if (mounted) setState(() => _state = _WriteState.success);
    } on NfcWriteFailure catch (e) {
      if (!mounted ||
          e.reason == NfcWriteError.cancelled && _state == _WriteState.success) {
        return;
      }
      setState(() {
        _state = _WriteState.failure;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = StatusColors.of(context);
    final (icon, colour, title, body) = switch (_state) {
      _WriteState.ready => (
        Icons.contactless_outlined,
        theme.colorScheme.primary,
        'Ready to write',
        'Hold an NFC tag flat against the back of your phone.',
      ),
      _WriteState.writing => (
        Icons.contactless,
        theme.colorScheme.primary,
        'Writing…',
        'Keep the tag still.',
      ),
      _WriteState.success => (
        Icons.check_circle,
        status.success,
        'Your card is on the tag',
        'Anyone who taps it will open your profile.',
      ),
      _WriteState.failure => (
        Icons.error_outline,
        theme.colorScheme.error,
        "Couldn't write the tag",
        _error ?? 'Try again.',
      ),
    };

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: colour),
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
            const SizedBox(height: 24),
            if (_state == _WriteState.writing) const LinearProgressIndicator(),
            if (_state == _WriteState.success)
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            if (_state == _WriteState.failure)
              FilledButton(onPressed: _write, child: const Text('Try again')),
            if (_state == _WriteState.ready ||
                _state == _WriteState.failure) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
