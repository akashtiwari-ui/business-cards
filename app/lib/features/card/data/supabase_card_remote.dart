import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/business_card.dart';
import '../domain/card_remote_data_source.dart';

class SupabaseCardRemote implements CardRemoteDataSource {
  SupabaseCardRemote(this._client);

  final SupabaseClient _client;

  @override
  Future<BusinessCard?> fetchMyCard(String userId) async {
    final row = await _client
        .from('cards')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> upsert(BusinessCard card, String userId) =>
      _client.from('cards').upsert(_toRow(card, userId));

  @override
  Future<bool> isSlugAvailable(String slug) async =>
      await _client.rpc<bool>('is_slug_available', params: {'p_slug': slug});

  BusinessCard _fromRow(Map<String, dynamic> row) => BusinessCard(
        id: row['id'] as String,
        slug: row['slug'] as String,
        name: row['name'] as String,
        title: row['title'] as String,
        company: row['company'] as String,
        phone: row['phone'] as String,
        email: row['email'] as String,
        website: row['website'] as String,
        linkedin: row['linkedin'] as String,
        location: row['location'] as String,
        bio: row['bio'] as String,
        links: (row['links'] as List)
            .map((e) => CardLink.fromJson(e as Map<String, dynamic>))
            .toList(),
        isPublic: row['is_public'] as bool,
        hidePhone: row['hide_phone'] as bool,
        hideEmail: row['hide_email'] as bool,
        updatedAt: DateTime.parse(row['updated_at'] as String).toLocal(),
      );

  Map<String, dynamic> _toRow(BusinessCard card, String userId) => {
        'id': card.id,
        'user_id': userId,
        'slug': card.slug,
        'name': card.name,
        'title': card.title,
        'company': card.company,
        'phone': card.phone,
        'email': card.email,
        'website': card.website,
        'linkedin': card.linkedin,
        'location': card.location,
        'bio': card.bio,
        'links': card.links.map((l) => l.toJson()).toList(),
        'is_public': card.isPublic,
        'hide_phone': card.hidePhone,
        'hide_email': card.hideEmail,
        'updated_at': card.updatedAt.toUtc().toIso8601String(),
      };
}
