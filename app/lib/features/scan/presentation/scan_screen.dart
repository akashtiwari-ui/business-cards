import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/home_shell.dart';
import '../../../app/theme.dart';
import '../../../core/platform/system_settings.dart';
import '../application/scan_providers.dart';
import '../application/scan_service.dart';
import 'scan_result_sheet.dart';

/// Full-screen QR scanner (PRD 4.4). The camera only runs while this tab is
/// showing and nothing covers it.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  static const tabIndex = 1;

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _controller = MobileScannerController(
    autoStart: false,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _busy = false;

  // The code stays in view after the sheet closes; don't re-open it at once.
  String? _lastRaw;
  DateTime _lastClosedAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    if (ref.read(currentTabProvider) == ScanScreen.tabIndex) _start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      await _controller.start();
    } catch (_) {
      // Shown by the scanner's error builder.
    }
  }

  Future<void> _stop() async {
    try {
      await _controller.stop();
    } catch (_) {}
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (raw == null || _busy) return;
    if (raw == _lastRaw &&
        DateTime.now().difference(_lastClosedAt) < const Duration(seconds: 3)) {
      return;
    }
    setState(() => _busy = true);
    HapticFeedback.selectionClick();

    final outcome = await ref.read(scanServiceProvider).handle(raw);
    if (!mounted) return;
    final action = await showModalBottomSheet<ScanSheetAction>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => ScanResultSheet(outcome: outcome),
    );
    if (!mounted) return;

    final contactId = switch (outcome) {
      ContactSaved(:final contact) ||
      AlreadySaved(:final contact) ||
      SavedOffline(:final contact) => contact.id,
      _ => null,
    };
    if (action == ScanSheetAction.review && contactId != null) {
      await _stop();
      if (mounted) await context.push('/contacts/$contactId');
      if (mounted && ref.read(currentTabProvider) == ScanScreen.tabIndex) {
        await _start();
      }
    } else if (action == ScanSheetAction.viewContacts) {
      context.go('/contacts');
    }
    _lastRaw = raw;
    _lastClosedAt = DateTime.now();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      currentTabProvider,
      (_, tab) => tab == ScanScreen.tabIndex ? _start() : _stop(),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = (constraints.maxWidth * 0.7).clamp(200.0, 320.0);
          final window = Rect.fromCenter(
            center: constraints.biggest.center(Offset.zero).translate(0, -24),
            width: side,
            height: side,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                scanWindow: window,
                errorBuilder: (context, error) => _CameraError(error: error),
              ),
              IgnorePointer(child: CustomPaint(painter: _FramePainter(window))),
              Positioned(
                top: window.bottom + 24,
                left: 24,
                right: 24,
                child: Text(
                  _busy
                      ? 'Reading card…'
                      : 'Align a profile QR code within the frame',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                    child: Row(
                      children: [
                        Text(
                          'Scan a card',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () async {
                            // Camera and Bluetooth scanning don't need to run together.
                            await _stop();
                            if (context.mounted) await context.push('/nearby');
                            if (mounted &&
                                ref.read(currentTabProvider) ==
                                    ScanScreen.tabIndex) {
                              await _start();
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.sensors),
                          label: const Text('Nearby'),
                        ),
                        _TorchButton(controller: _controller),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, _) {
        if (!state.isRunning || state.torchState == TorchState.unavailable) {
          return const SizedBox(height: 48);
        }
        final on = state.torchState == TorchState.on;
        return IconButton(
          tooltip: on ? 'Turn torch off' : 'Turn torch on',
          onPressed: controller.toggleTorch,
          icon: Icon(
            on ? Icons.flashlight_on : Icons.flashlight_off,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

/// Dims everything outside the scan window and draws its rounded corners.
class _FramePainter extends CustomPainter {
  _FramePainter(this.window);

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(window, const Radius.circular(24));
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(frame),
      ),
      Paint()..color = Colors.black54,
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.window != window;
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.no_photography_outlined,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                denied ? 'Camera access is off' : "Camera isn't available",
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                denied
                    ? 'Allow camera access in Settings to scan business cards.'
                    : 'Close other apps using the camera and try again.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (denied) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: openAppSettings,
                  child: const Text('Open settings'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
