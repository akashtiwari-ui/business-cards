import 'dart:convert';

import 'package:b_card/features/nfc/domain/ndef_uri.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compresses the https:// prefix to code 0x04', () {
    final payload = encodeUriPayload('https://b-cards.vercel.app/p/aarav');
    expect(payload.first, 0x04);
    expect(utf8.decode(payload.sublist(1)), 'b-cards.vercel.app/p/aarav');
  });

  test('prefers the longer https://www. prefix', () {
    expect(encodeUriPayload('https://www.example.com').first, 0x02);
    expect(encodeUriPayload('http://www.example.com').first, 0x01);
    expect(encodeUriPayload('http://example.com').first, 0x03);
    expect(encodeUriPayload('tel:+91').first, 0x00);
  });

  test('builds a single short URI record', () {
    final bytes = encodeUriNdefMessage('https://b-cards.vercel.app/p/aarav');
    final payload = encodeUriPayload('https://b-cards.vercel.app/p/aarav');

    expect(bytes[0], 0xD1); // MB | ME | SR | TNF well-known
    expect(bytes[1], 1); // type length
    expect(bytes[2], payload.length); // payload length
    expect(bytes[3], 0x55); // 'U'
    expect(bytes.sublist(4), payload);
  });

  test('switches to a long record for payloads over 255 bytes', () {
    final url = 'https://example.com/${'a' * 300}';
    final bytes = encodeUriNdefMessage(url);
    final payloadLength = encodeUriPayload(url).length;

    expect(bytes[0], 0xC1); // no SR flag
    expect(
      (bytes[2] << 24) | (bytes[3] << 16) | (bytes[4] << 8) | bytes[5],
      payloadLength,
    );
    expect(bytes[6], 0x55);
    expect(bytes.length, 7 + payloadLength);
  });
}
