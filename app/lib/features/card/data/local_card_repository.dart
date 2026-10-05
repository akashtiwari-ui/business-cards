import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/business_card.dart';
import '../domain/card_repository.dart';

/// Cards stored on the phone. [ownerId] scopes every read and write to the
/// signed-in user; it is null in the offline-only build.
class LocalCardRepository implements CardRepository {
  LocalCardRepository(this._db, {this.ownerId});

  final AppDatabase _db;
  final String? ownerId;

  Expression<bool> _ownedBy($CardsTable c) =>
      ownerId == null ? c.ownerId.isNull() : c.ownerId.equals(ownerId!);

  @override
  Stream<BusinessCard?> watchMyCard() {
    final query = _db.select(_db.cards)
      ..where(_ownedBy)
      ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)])
      ..limit(1);
    return query.watchSingleOrNull().map((row) => row == null ? null : _toDomain(row));
  }

  @override
  Future<void> save(BusinessCard card) =>
      _db.into(_db.cards).insertOnConflictUpdate(_toCompanion(card, pendingSync: true));

  @override
  Future<void> setVisibility(String cardId, {required bool isPublic}) =>
      (_db.update(_db.cards)..where((c) => c.id.equals(cardId) & _ownedBy(c))).write(
        CardsCompanion(
          isPublic: Value(isPublic),
          updatedAt: Value(DateTime.now()),
          pendingSync: const Value(true),
        ),
      );

  /// Stores the server copy unless the local card has unsynced edits.
  Future<void> saveFromRemote(BusinessCard card) => _db.transaction(() async {
        final existing = await (_db.select(_db.cards)..where((c) => c.id.equals(card.id)))
            .getSingleOrNull();
        if (existing?.pendingSync ?? false) return;
        await _db.into(_db.cards).insertOnConflictUpdate(_toCompanion(card, pendingSync: false));
      });

  /// Clears the pending flag, unless the card was edited again since [updatedAt].
  Future<void> markSynced(String cardId, DateTime updatedAt) =>
      (_db.update(_db.cards)
            ..where((c) => c.id.equals(cardId) & c.updatedAt.equals(updatedAt)))
          .write(const CardsCompanion(pendingSync: Value(false)));

  BusinessCard _toDomain(CardRow row) => BusinessCard(
        id: row.id,
        slug: row.slug,
        name: row.name,
        title: row.title,
        company: row.company,
        phone: row.phone,
        email: row.email,
        website: row.website,
        linkedin: row.linkedin,
        location: row.location,
        bio: row.bio,
        links: (jsonDecode(row.linksJson) as List)
            .map((e) => CardLink.fromJson(e as Map<String, dynamic>))
            .toList(),
        isPublic: row.isPublic,
        hidePhone: row.hidePhone,
        hideEmail: row.hideEmail,
        updatedAt: row.updatedAt,
        syncPending: row.pendingSync,
      );

  CardsCompanion _toCompanion(BusinessCard card, {required bool pendingSync}) =>
      CardsCompanion.insert(
        id: card.id,
        ownerId: Value(ownerId),
        slug: card.slug,
        name: card.name,
        title: Value(card.title),
        company: Value(card.company),
        phone: Value(card.phone),
        email: Value(card.email),
        website: Value(card.website),
        linkedin: Value(card.linkedin),
        location: Value(card.location),
        bio: Value(card.bio),
        linksJson: Value(jsonEncode(card.links.map((l) => l.toJson()).toList())),
        isPublic: Value(card.isPublic),
        hidePhone: Value(card.hidePhone),
        hideEmail: Value(card.hideEmail),
        updatedAt: card.updatedAt,
        pendingSync: Value(pendingSync),
      );
}
