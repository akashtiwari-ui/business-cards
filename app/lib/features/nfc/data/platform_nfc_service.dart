import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

import '../domain/ndef_uri.dart';
import '../domain/nfc_service.dart';

/// Tag writing through nfc_manager; tap-to-share through our own Android
/// host card emulation service (see NdefCardService.kt).
class PlatformNfcService implements NfcService {
  static const _channel = MethodChannel('com.bcard/nfc');

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<NfcSupport> availability() async {
    try {
      return switch (await NfcManager.instance.checkAvailability()) {
        NfcAvailability.enabled => NfcSupport.enabled,
        NfcAvailability.disabled => NfcSupport.disabled,
        NfcAvailability.unsupported => NfcSupport.unsupported,
      };
    } catch (_) {
      return NfcSupport.unsupported;
    }
  }

  @override
  Future<void> writeUrl(String url, {void Function()? onTagDetected}) {
    final done = Completer<void>();
    final message = NdefMessage(records: [
      NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x55]), // 'U'
        identifier: Uint8List(0),
        payload: encodeUriPayload(url),
      ),
    ]);

    void fail(NfcWriteError reason) {
      if (!done.isCompleted) done.completeError(NfcWriteFailure(reason));
    }

    NfcManager.instance
        .startSession(
          pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
          alertMessageIos: 'Hold the NFC tag near the top of your iPhone.',
          onSessionErrorIos: (_) => fail(NfcWriteError.cancelled),
          onDiscovered: (tag) async {
            onTagDetected?.call();
            try {
              final ndef = Ndef.from(tag);
              if (ndef == null) throw const NfcWriteFailure(NfcWriteError.notNdef);
              if (!ndef.isWritable) throw const NfcWriteFailure(NfcWriteError.readOnly);
              if (message.byteLength > ndef.maxSize) throw const NfcWriteFailure(NfcWriteError.tooSmall);
              await ndef.write(message: message);
              await NfcManager.instance.stopSession(alertMessageIos: 'Your card is on the tag.');
              if (!done.isCompleted) done.complete();
            } on NfcWriteFailure catch (e) {
              await NfcManager.instance.stopSession(errorMessageIos: e.message);
              fail(e.reason);
            } catch (_) {
              await NfcManager.instance.stopSession(errorMessageIos: 'Could not write the tag.');
              fail(NfcWriteError.lostConnection);
            }
          },
        )
        .catchError((Object _) => fail(NfcWriteError.cancelled));

    return done.future;
  }

  @override
  Future<void> cancelWrite() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {
      // No session running.
    }
  }

  @override
  Future<bool> supportsTapToShare() async {
    if (!_isAndroid) return false;
    return await _channel.invokeMethod<bool>('supportsCardEmulation') ?? false;
  }

  @override
  Future<void> startTapToShare(String url) async {
    if (!_isAndroid) return;
    await _channel.invokeMethod<void>('startCardEmulation', {'ndef': encodeUriNdefMessage(url)});
  }

  @override
  Future<void> stopTapToShare() async {
    if (!_isAndroid) return;
    await _channel.invokeMethod<void>('stopCardEmulation');
  }

  @override
  Future<void> openSettings() async {
    if (!_isAndroid) return;
    await _channel.invokeMethod<void>('openNfcSettings');
  }
}
