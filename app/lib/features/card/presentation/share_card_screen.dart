import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../nfc/presentation/nfc_share_panel.dart';
import '../application/card_providers.dart';

/// QR code, link and NFC sharing (PRD 4.3). The QR and NFC tag carry only the
/// permanent profile URL, never personal data.
class ShareCardScreen extends ConsumerStatefulWidget {
  const ShareCardScreen({super.key});

  @override
  ConsumerState<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends ConsumerState<ShareCardScreen> {
  @override
  void initState() {
    super.initState();
    _setBrightness(max: true);
  }

  @override
  void dispose() {
    _setBrightness(max: false);
    super.dispose();
  }

  Future<void> _setBrightness({required bool max}) async {
    try {
      final brightness = ScreenBrightness.instance;
      max
          ? await brightness.setApplicationScreenBrightness(1.0)
          : await brightness.resetApplicationScreenBrightness();
    } catch (_) {
      // Unsupported platform or permission: sharing still works.
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(myCardProvider).value;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Share card'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.qr_code_2), text: 'QR code'),
              Tab(icon: Icon(Icons.nfc), text: 'NFC'),
            ],
          ),
        ),
        body: card == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (!card.isPublic)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: StatusColors.of(context).warningContainer,
                            borderRadius: BorderRadius.circular(16),
                            child: ListTile(
                              leading: Icon(
                                Icons.visibility_off_outlined,
                                color: StatusColors.of(context).warning,
                              ),
                              title: const Text('Your profile is hidden'),
                              subtitle: const Text(
                                'People who scan will see "Profile unavailable".',
                              ),
                            ),
                          ),
                        ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            // QR stays dark-on-white in dark mode so every scanner reads it.
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          child: QrImageView(
                            data: AppConfig.profileUrl(card.slug),
                            size: 240,
                            // Level Q leaves room for a centre logo (PRD requires >= M).
                            errorCorrectionLevel: QrErrorCorrectLevel.Q,
                            semanticsLabel:
                                'QR code for ${card.name}\'s profile',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        card.name,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        'Scan to view my profile',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _LinkRow(url: AppConfig.profileUrl(card.slug)),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => SharePlus.instance.share(
                          ShareParams(
                            text:
                                'Here is my digital business card: ${AppConfig.profileUrl(card.slug)}',
                            subject: card.name,
                          ),
                        ),
                        icon: const Icon(Icons.share),
                        label: const Text('Share link'),
                      ),
                    ],
                  ),
                  NfcSharePanel(url: AppConfig.profileUrl(card.slug)),
                ],
              ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.link, color: scheme.primary),
        ),
        title: Text(url, overflow: TextOverflow.ellipsis),
        trailing: TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Link copied')));
            }
          },
          child: const Text('Copy link'),
        ),
      ),
    );
  }
}
