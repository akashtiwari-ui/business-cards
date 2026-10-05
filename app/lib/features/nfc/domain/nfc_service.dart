/// NFC sharing (PRD 4.3): write the profile link to a tag, or let the phone
/// itself act as a tag ("tap phones to share", Android only).
library;

enum NfcSupport { enabled, disabled, unsupported }

enum NfcWriteError { notNdef, readOnly, tooSmall, lostConnection, cancelled }

class NfcWriteFailure implements Exception {
  const NfcWriteFailure(this.reason);

  final NfcWriteError reason;

  String get message => switch (reason) {
        NfcWriteError.notNdef => "This tag can't store a link. Use an NTAG213, 215 or 216 sticker or card.",
        NfcWriteError.readOnly => 'This tag is locked and cannot be changed.',
        NfcWriteError.tooSmall => 'This tag is too small for your link.',
        NfcWriteError.lostConnection => 'The tag moved away too soon. Hold it still and try again.',
        NfcWriteError.cancelled => 'Writing was cancelled.',
      };

  @override
  String toString() => message;
}

abstract interface class NfcService {
  Future<NfcSupport> availability();

  /// Waits for a tag, then overwrites it with [url]. [onTagDetected] fires as
  /// soon as a tag is in range. Throws [NfcWriteFailure].
  Future<void> writeUrl(String url, {void Function()? onTagDetected});

  /// Stops waiting for a tag.
  Future<void> cancelWrite();

  /// Whether this phone can act as a tag itself (Android host card emulation).
  Future<bool> supportsTapToShare();

  /// Serves [url] to any phone that taps this one, until [stopTapToShare].
  Future<void> startTapToShare(String url);

  Future<void> stopTapToShare();

  /// Opens the system NFC settings (Android); a no-op elsewhere.
  Future<void> openSettings();
}
