import 'dart:async';

import 'package:b_card/app/theme.dart';
import 'package:b_card/features/nfc/application/nfc_providers.dart';
import 'package:b_card/features/nfc/domain/nfc_service.dart';
import 'package:b_card/features/nfc/presentation/nfc_share_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNfcService implements NfcService {
  FakeNfcService({this.support = NfcSupport.enabled, this.tapToShare = true});

  NfcSupport support;
  bool tapToShare;
  String? sharing;
  bool settingsOpened = false;
  Completer<void>? pendingWrite;
  void Function()? onTagDetected;
  String? writtenUrl;

  @override
  Future<NfcSupport> availability() async => support;

  @override
  Future<bool> supportsTapToShare() async => tapToShare;

  @override
  Future<void> startTapToShare(String url) async => sharing = url;

  @override
  Future<void> stopTapToShare() async => sharing = null;

  @override
  Future<void> openSettings() async => settingsOpened = true;

  String? savedLink = 'https://b-cards.vercel.app/p/aarav';
  bool alwaysOn = false;
  bool tileRequested = false;

  @override
  Future<void> saveShareLink(String? url) async => savedLink = url;

  @override
  Future<bool> isAlwaysOn() async => alwaysOn;

  @override
  Future<bool> setAlwaysOn(bool on) async => alwaysOn = on && savedLink != null;

  @override
  Future<bool> canAddQuickSettingsTile() async => true;

  @override
  Future<void> addQuickSettingsTile() async => tileRequested = true;

  @override
  Future<void> writeUrl(String url, {void Function()? onTagDetected}) {
    writtenUrl = url;
    this.onTagDetected = onTagDetected;
    return (pendingWrite = Completer<void>()).future;
  }

  @override
  Future<void> cancelWrite() async {
    if (!(pendingWrite?.isCompleted ?? true)) {
      pendingWrite!.completeError(
        const NfcWriteFailure(NfcWriteError.cancelled),
      );
    }
  }
}

const _url = 'https://b-cards.vercel.app/p/aarav';

Widget _panel(FakeNfcService nfc) => ProviderScope(
  overrides: [nfcServiceProvider.overrideWithValue(nfc)],
  child: MaterialApp(
    theme: AppTheme.light,
    home: const Scaffold(body: NfcSharePanel(url: _url)),
  ),
);

void main() {
  testWidgets('phones without NFC are pointed to the QR code', (tester) async {
    await tester.pumpWidget(
      _panel(FakeNfcService(support: NfcSupport.unsupported)),
    );
    await tester.pumpAndSettle();
    expect(find.text("This phone doesn't have NFC"), findsOneWidget);
  });

  testWidgets('NFC switched off offers the settings screen', (tester) async {
    final nfc = FakeNfcService(support: NfcSupport.disabled);
    await tester.pumpWidget(_panel(nfc));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open NFC settings'));
    expect(nfc.settingsOpened, isTrue);
  });

  testWidgets('tap to share runs while the panel is open', (tester) async {
    final nfc = FakeNfcService();
    await tester.pumpWidget(_panel(nfc));
    await tester.pumpAndSettle();

    expect(nfc.sharing, _url);
    expect(find.text('Ready to share'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    expect(nfc.sharing, isNull);
  });

  testWidgets('phones without card emulation can still write tags', (
    tester,
  ) async {
    final nfc = FakeNfcService(tapToShare: false);
    await tester.pumpWidget(_panel(nfc));
    await tester.pumpAndSettle();

    expect(nfc.sharing, isNull);
    expect(find.textContaining("can't share by tapping"), findsOneWidget);
    expect(find.text('Write to NFC tag'), findsOneWidget);
  });

  testWidgets('writing a tag goes ready → writing → success', (tester) async {
    final nfc = FakeNfcService();
    await tester.pumpWidget(_panel(nfc));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Write to NFC tag'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to write'), findsOneWidget);
    expect(nfc.writtenUrl, _url);
    expect(nfc.sharing, isNull, reason: 'tap to share pauses while writing');

    nfc.onTagDetected!();
    await tester.pump();
    expect(find.text('Writing…'), findsOneWidget);

    nfc.pendingWrite!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Your card is on the tag'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(
      nfc.sharing,
      _url,
      reason: 'tap to share resumes after the sheet closes',
    );
  });

  testWidgets('a locked tag shows the reason and can be retried', (
    tester,
  ) async {
    final nfc = FakeNfcService();
    await tester.pumpWidget(_panel(nfc));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Write to NFC tag'));
    await tester.pumpAndSettle();

    nfc.pendingWrite!.completeError(
      const NfcWriteFailure(NfcWriteError.readOnly),
    );
    await tester.pumpAndSettle();
    expect(find.text("Couldn't write the tag"), findsOneWidget);
    expect(
      find.text('This tag is locked and cannot be changed.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to write'), findsOneWidget);
  });

  testWidgets(
    'Always on keeps sharing after leaving and can add a Quick Settings tile',
    (tester) async {
      final nfc = FakeNfcService();
      await tester.pumpWidget(_panel(nfc));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Always on'));
      await tester.pumpAndSettle();
      expect(nfc.alwaysOn, isTrue);

      await tester.tap(find.text('Add to Quick Settings'));
      expect(nfc.tileRequested, isTrue);

      await tester.pumpWidget(const SizedBox());
      expect(
        nfc.alwaysOn,
        isTrue,
        reason: 'leaving the tab does not switch it off',
      );
    },
  );

  testWidgets('Always on stays off when there is no public link to share', (
    tester,
  ) async {
    final nfc = FakeNfcService()..savedLink = null;
    await tester.pumpWidget(_panel(nfc));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Always on'));
    await tester.pumpAndSettle();
    expect(nfc.alwaysOn, isFalse);
    expect(find.textContaining('Make your profile public'), findsOneWidget);
  });
}
