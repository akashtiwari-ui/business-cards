/// NFC Forum URI record encoding (URI RTD 1.0): the profile link that phones
/// open when they tap a B Card tag or a phone sharing in tap mode.
library;

import 'dart:convert';
import 'dart:typed_data';

/// URI identifier codes, longest prefix first so `https://www.` wins over `https://`.
const _prefixes = <(int, String)>[
  (0x02, 'https://www.'),
  (0x01, 'http://www.'),
  (0x04, 'https://'),
  (0x03, 'http://'),
];

/// Record payload: one prefix byte, then the rest of the URI as UTF-8.
Uint8List encodeUriPayload(String uri) {
  for (final (code, prefix) in _prefixes) {
    if (uri.startsWith(prefix)) {
      return Uint8List.fromList([code, ...utf8.encode(uri.substring(prefix.length))]);
    }
  }
  return Uint8List.fromList([0x00, ...utf8.encode(uri)]);
}

/// A complete one-record NDEF message holding [uri], as stored in an NFC
/// Forum Type 4 tag's NDEF file (without the 2-byte length prefix).
Uint8List encodeUriNdefMessage(String uri) {
  final payload = encodeUriPayload(uri);
  final short = payload.length < 256;
  // MB | ME | (SR) | TNF=well-known
  final header = 0x80 | 0x40 | (short ? 0x10 : 0x00) | 0x01;
  final length = short
      ? [payload.length]
      : [(payload.length >> 24) & 0xFF, (payload.length >> 16) & 0xFF, (payload.length >> 8) & 0xFF, payload.length & 0xFF];
  return Uint8List.fromList([header, 0x01, ...length, 0x55 /* 'U' */, ...payload]);
}
