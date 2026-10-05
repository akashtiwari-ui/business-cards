import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/nearby_ports.dart';

class SupabaseBeaconRegistry implements BeaconRegistry {
  SupabaseBeaconRegistry(this._client);

  final SupabaseClient _client;

  @override
  Future<void> register({
    required String cardId,
    required String token,
    required DateTime expiresAt,
  }) async {
    // One live token per card: older ones stop resolving at once.
    await _client.from('beacon_tokens').delete().eq('card_id', cardId);
    await _client.from('beacon_tokens').insert({
      'token': token,
      'card_id': cardId,
      'expires_at': expiresAt.toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<NearbyProfile>> resolve(List<String> tokens) async {
    if (tokens.isEmpty) return const [];
    final rows = await _client.rpc<List<dynamic>>(
      'resolve_beacon_tokens',
      params: {'p_tokens': tokens},
    );
    return rows
        .cast<Map<String, dynamic>>()
        .map(
          (r) => NearbyProfile(
            token: r['token'] as String,
            cardId: r['card_id'] as String,
            slug: r['slug'] as String,
            name: r['name'] as String,
            title: r['title'] as String? ?? '',
            company: r['company'] as String? ?? '',
          ),
        )
        .toList();
  }
}
