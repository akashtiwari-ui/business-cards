import 'business_card.dart';

/// Server copy of the user's card. Implementations throw on network or
/// server errors; callers decide whether to retry.
abstract interface class CardRemoteDataSource {
  Future<BusinessCard?> fetchMyCard(String userId);

  Future<void> upsert(BusinessCard card, String userId);

  Future<bool> isSlugAvailable(String slug);
}
