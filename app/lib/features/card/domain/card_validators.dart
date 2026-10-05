/// Input validation for the card editor (PRD 4.1, 6.1).
/// Each validator returns an error message, or null when valid.
library;

const reservedSlugs = {
  'about', 'admin', 'api', 'app', 'auth', 'bcard', 'b-card', 'help',
  'login', 'logout', 'p', 'privacy', 'settings', 'signup', 'support',
  'terms', 'www',
};

final _slugPattern = RegExp(r'^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$');
final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _phonePattern = RegExp(r'^\+?[0-9 ()-]{7,20}$');

String? validateSlug(String? value) {
  final slug = value?.trim() ?? '';
  if (slug.isEmpty) return 'Choose a profile link';
  if (!_slugPattern.hasMatch(slug)) {
    return '3-30 lowercase letters, numbers or hyphens';
  }
  if (slug.contains('--')) return 'Avoid double hyphens';
  if (reservedSlugs.contains(slug)) return 'This link is reserved';
  return null;
}

String? validateName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Name is required';
  if (name.length > 80) return 'Keep it under 80 characters';
  return null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return null;
  return _emailPattern.hasMatch(email) ? null : 'Enter a valid email';
}

String? validatePhone(String? value) {
  final phone = value?.trim() ?? '';
  if (phone.isEmpty) return null;
  return _phonePattern.hasMatch(phone) ? null : 'Enter a valid phone number';
}

String? validateUrl(String? value) {
  final url = normalizeUrl(value ?? '');
  if (url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  final ok = uri != null && uri.host.contains('.') && !uri.host.contains(' ');
  return ok ? null : 'Enter a valid link';
}

/// Adds `https://` when the user typed a bare domain.
String normalizeUrl(String value) {
  final url = value.trim();
  if (url.isEmpty) return '';
  return RegExp(r'^https?://', caseSensitive: false).hasMatch(url)
      ? url
      : 'https://$url';
}

/// Suggests a slug from a display name: "Aarav Shah" -> "aarav-shah".
String suggestSlug(String name) {
  var slug = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  if (slug.length > 30) {
    slug = slug.substring(0, 30).replaceAll(RegExp(r'-+$'), '');
  }
  return slug;
}
