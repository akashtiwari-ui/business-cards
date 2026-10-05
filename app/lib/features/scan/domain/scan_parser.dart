import 'package:flutter/foundation.dart';

/// What a scanned QR code contains (PRD 4.4).
sealed class ScanPayload {
  const ScanPayload();
}

/// A B Card profile link: the details are fetched from the server.
class BCardLink extends ScanPayload {
  const BCardLink(this.slug);

  final String slug;
}

/// Contact details carried in the code itself (vCard or MECARD), e.g. from
/// other business card apps.
class ContactDetails extends ScanPayload {
  const ContactDetails({
    required this.name,
    this.title = '',
    this.company = '',
    this.email = '',
    this.phone = '',
    this.website = '',
    this.location = '',
    this.notes = '',
  });

  final String name;
  final String title;
  final String company;
  final String email;
  final String phone;
  final String website;
  final String location;
  final String notes;
}

/// Anything else: a plain link, Wi-Fi code, payment code…
class NotAContact extends ScanPayload {
  const NotAContact(this.text);

  final String text;
}

final _slugPattern = RegExp(r'^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$');

ScanPayload parseScan(String raw, {required String profileBaseUrl}) {
  final text = raw.trim();
  if (text.isEmpty) return NotAContact(text);

  final slug = _profileSlug(text, profileBaseUrl);
  if (slug != null) return BCardLink(slug);

  final upper = text.toUpperCase();
  if (upper.startsWith('BEGIN:VCARD')) return _parseVCard(text) ?? NotAContact(text);
  if (upper.startsWith('MECARD:')) return _parseMeCard(text) ?? NotAContact(text);
  return NotAContact(text);
}

/// `https://host/p/<slug>` on our profile host, any scheme or trailing slash.
String? _profileSlug(String text, String profileBaseUrl) {
  final uri = Uri.tryParse(text);
  final base = Uri.tryParse(profileBaseUrl);
  if (uri == null || base == null || !uri.hasAuthority) return null;
  if (!{'http', 'https'}.contains(uri.scheme) || uri.host.toLowerCase() != base.host.toLowerCase()) return null;

  final baseSegments = base.pathSegments.where((s) => s.isNotEmpty).toList();
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length != baseSegments.length + 1 || !listEquals(segments.sublist(0, baseSegments.length), baseSegments)) {
    return null;
  }
  final slug = segments.last.toLowerCase();
  return _slugPattern.hasMatch(slug) ? slug : null;
}

ContactDetails? _parseVCard(String text) {
  // Unfold continuation lines (RFC 6350 §3.2), then read "NAME;params:value".
  final lines = text.replaceAll('\r\n', '\n').replaceAll(RegExp(r'\n[ \t]'), '').split('\n');
  final fields = <String, String>{};
  String? structuredName;

  for (final line in lines) {
    final colon = line.indexOf(':');
    if (colon <= 0) continue;
    final key = line.substring(0, colon).split(';').first.split('.').last.toUpperCase();
    final value = line.substring(colon + 1).trim();
    if (value.isEmpty) continue;
    if (key == 'N') {
      structuredName = value;
    } else if (key == 'ADR') {
      fields.putIfAbsent('ADR', () => _splitEscaped(value, ';').where((p) => p.isNotEmpty).join(', '));
    } else {
      fields.putIfAbsent(key, () => _unescape(value));
    }
  }

  var name = fields['FN'] ?? '';
  if (name.isEmpty && structuredName != null) {
    final parts = _splitEscaped(structuredName, ';');
    name = [parts.length > 1 ? parts[1] : '', parts.first].where((p) => p.isNotEmpty).join(' ');
  }
  if (name.isEmpty) return null;

  return ContactDetails(
    name: name,
    title: fields['TITLE'] ?? '',
    company: _splitEscaped(fields['ORG'] ?? '', ';').first,
    email: fields['EMAIL'] ?? '',
    phone: fields['TEL'] ?? '',
    website: fields['URL'] ?? '',
    location: fields['ADR'] ?? '',
    notes: fields['NOTE'] ?? '',
  );
}

ContactDetails? _parseMeCard(String text) {
  final body = text.substring('MECARD:'.length);
  final fields = <String, String>{};
  for (final part in _splitEscaped(body, ';')) {
    final colon = part.indexOf(':');
    if (colon <= 0) continue;
    fields.putIfAbsent(part.substring(0, colon).toUpperCase(), () => part.substring(colon + 1));
  }
  final rawName = fields['N'] ?? '';
  // MECARD names are "Last,First".
  final nameParts = _splitEscaped(rawName, ',');
  final name = (nameParts.length > 1 ? '${nameParts[1]} ${nameParts[0]}' : rawName).trim();
  if (name.isEmpty) return null;

  return ContactDetails(
    name: name,
    company: fields['ORG'] ?? '',
    email: fields['EMAIL'] ?? '',
    phone: fields['TEL'] ?? '',
    website: fields['URL'] ?? '',
    location: fields['ADR'] ?? '',
    notes: fields['NOTE'] ?? '',
  );
}

/// Splits on [separator] unless it is backslash-escaped, then unescapes parts.
List<String> _splitEscaped(String value, String separator) {
  final parts = <String>[];
  final current = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    final char = value[i];
    if (char == r'\' && i + 1 < value.length) {
      current
        ..write(char)
        ..write(value[++i]);
    } else if (char == separator) {
      parts.add(_unescape(current.toString()));
      current.clear();
    } else {
      current.write(char);
    }
  }
  parts.add(_unescape(current.toString()));
  return parts.map((p) => p.trim()).toList();
}

String _unescape(String value) => value
    .replaceAll(r'\n', '\n')
    .replaceAll(r'\N', '\n')
    .replaceAllMapped(RegExp(r'\\([,;:\\])'), (m) => m[1]!);
