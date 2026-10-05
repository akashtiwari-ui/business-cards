import 'package:supabase_flutter/supabase_flutter.dart';

import '../../card/domain/business_card.dart';
import '../domain/public_profile_source.dart';

/// Reads the `public_cards` view, which already drops hidden cards and fields.
class SupabasePublicProfileSource implements PublicProfileSource {
  SupabasePublicProfileSource(this._client);

  final SupabaseClient _client;

  @override
  Future<PublicProfile?> fetchBySlug(String slug) async {
    final row = await _client
        .from('public_cards')
        .select()
        .eq('slug', slug)
        .maybeSingle()
        .timeout(const Duration(seconds: 6));
    if (row == null) return null;
    return PublicProfile(
      cardId: row['id'] as String,
      slug: row['slug'] as String,
      name: row['name'] as String,
      title: row['title'] as String? ?? '',
      company: row['company'] as String? ?? '',
      email: row['email'] as String? ?? '',
      phone: row['phone'] as String? ?? '',
      website: row['website'] as String? ?? '',
      linkedin: row['linkedin'] as String? ?? '',
      location: row['location'] as String? ?? '',
      links: ((row['links'] as List?) ?? const [])
          .map((e) => CardLink.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
