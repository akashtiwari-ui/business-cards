/// Build-time configuration, supplied with `--dart-define`.
///
/// Example:
/// flutter run --dart-define-from-file=config/supabase.json \
///   --dart-define=PROFILE_BASE_URL=https://bcard.link/p
abstract final class AppConfig {
  /// Base of the permanent public profile URL encoded in every QR code.
  /// Must be a domain we own forever: printed QR codes cannot change.
  static const profileBaseUrl = String.fromEnvironment(
    'PROFILE_BASE_URL',
    defaultValue: 'https://bcard.example/p',
  );

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static String profileUrl(String slug) => '$profileBaseUrl/$slug';
}
