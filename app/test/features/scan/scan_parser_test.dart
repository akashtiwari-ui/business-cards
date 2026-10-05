import 'package:b_card/features/scan/domain/scan_parser.dart';
import 'package:flutter_test/flutter_test.dart';

const _base = 'https://b-cards.vercel.app/p';

ScanPayload _parse(String raw) => parseScan(raw, profileBaseUrl: _base);

void main() {
  group('B Card links', () {
    test('recognises our profile URL in its common forms', () {
      for (final raw in [
        'https://b-cards.vercel.app/p/akash-tiwari',
        'https://b-cards.vercel.app/p/akash-tiwari/',
        'http://B-CARDS.vercel.app/p/Akash-Tiwari',
        'https://b-cards.vercel.app/p/akash-tiwari?ref=qr',
      ]) {
        expect(_parse(raw), isA<BCardLink>().having((p) => p.slug, 'slug', 'akash-tiwari'), reason: raw);
      }
    });

    test('ignores other hosts, paths and malformed slugs', () {
      for (final raw in [
        'https://evil.example/p/akash-tiwari',
        'https://b-cards.vercel.app/x/akash-tiwari',
        'https://b-cards.vercel.app/p/akash-tiwari/vcard',
        'https://b-cards.vercel.app/p/a',
        'javascript:alert(1)',
      ]) {
        expect(_parse(raw), isA<NotAContact>(), reason: raw);
      }
    });
  });

  test('reads a vCard with folded lines and escapes', () {
    const vcard = 'BEGIN:VCARD\r\nVERSION:3.0\r\nN:Shah;Priya;;;\r\nFN:Priya Shah\r\nORG:Acme\\, Inc;Sales\r\n'
        'TITLE:Head of Sales\r\nTEL;TYPE=CELL:+91 98765 43210\r\nEMAIL;TYPE=INTERNET:priya@acme.in\r\n'
        'URL:https://acme.in\r\nADR;TYPE=WORK:;;MG Road;Pune;;411001;India\r\nNOTE:Met at\r\n  the expo\r\nEND:VCARD';
    final details = _parse(vcard) as ContactDetails;

    expect(details.name, 'Priya Shah');
    expect(details.company, 'Acme, Inc');
    expect(details.title, 'Head of Sales');
    expect(details.phone, '+91 98765 43210');
    expect(details.email, 'priya@acme.in');
    expect(details.website, 'https://acme.in');
    expect(details.location, 'MG Road, Pune, 411001, India');
    expect(details.notes, 'Met at the expo');
  });

  test('builds the name from N when FN is missing', () {
    final details = _parse('BEGIN:VCARD\nVERSION:3.0\nN:Rao;Kabir;;;\nEND:VCARD') as ContactDetails;
    expect(details.name, 'Kabir Rao');
  });

  test('reads MECARD codes', () {
    final details = _parse('MECARD:N:Mehta,Isha;TEL:+919812345678;EMAIL:isha@x.in;ORG:Studio;;') as ContactDetails;
    expect(details.name, 'Isha Mehta');
    expect(details.phone, '+919812345678');
    expect(details.company, 'Studio');
  });

  test('anything else is not a contact', () {
    expect(_parse('WIFI:S:Office;T:WPA;P:secret;;'), isA<NotAContact>());
    expect(_parse('https://example.com'), isA<NotAContact>());
    expect(_parse('BEGIN:VCARD\nEND:VCARD'), isA<NotAContact>());
  });
}
