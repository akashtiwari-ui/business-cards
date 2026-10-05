import 'business_card.dart';

/// Source of truth for the user's own card. Local-first: writes land in the
/// on-device database and are synced to the backend later.
abstract interface class CardRepository {
  /// Emits the user's card, or null before one is created.
  Stream<BusinessCard?> watchMyCard();

  /// Inserts or replaces the card.
  Future<void> save(BusinessCard card);

  Future<void> setVisibility(String cardId, {required bool isPublic});
}
