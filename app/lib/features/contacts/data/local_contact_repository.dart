import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../card/domain/business_card.dart';
import '../domain/contact.dart';
import '../domain/contact_repository.dart';

/// Contacts on the phone, scoped to the signed-in user like the card.
class LocalContactRepository implements ContactRepository {
  LocalContactRepository(this._db, {this.ownerId});

  final AppDatabase _db;
  final String? ownerId;

  Expression<bool> _ownedBy($ContactsTable c) =>
      ownerId == null ? c.ownerId.isNull() : c.ownerId.equals(ownerId!);

  SimpleSelectStatement<$ContactsTable, ContactRow> _owned() =>
      _db.select(_db.contacts)..where(_ownedBy);

  @override
  Stream<List<Contact>> watchAll() => (_owned()
        ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
      .watch()
      .map((rows) => rows.map(_toDomain).toList());

  @override
  Stream<Contact?> watch(String id) => (_owned()..where((c) => c.id.equals(id)))
      .watchSingleOrNull()
      .map((row) => row == null ? null : _toDomain(row));

  @override
  Future<Contact?> findBySlug(String slug) async {
    final row = await (_owned()
          ..where((c) => c.sourceSlug.equals(slug))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Contact?> findByEmailOrPhone({required String email, required String phone}) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (email.isEmpty && digits.length < 7) return null;
    final rows = await _owned().get();
    for (final row in rows) {
      final sameEmail = email.isNotEmpty && row.email.toLowerCase() == email.toLowerCase();
      final rowDigits = row.phone.replaceAll(RegExp(r'\D'), '');
      final samePhone = digits.length >= 7 && rowDigits.length >= 7 &&
          (rowDigits.endsWith(digits) || digits.endsWith(rowDigits));
      if (sameEmail || samePhone) return _toDomain(row);
    }
    return null;
  }

  @override
  Future<List<Contact>> pendingProfiles() async =>
      (await (_owned()..where((c) => c.profilePending.equals(true))).get()).map(_toDomain).toList();

  @override
  Future<void> save(Contact contact) => _db.into(_db.contacts).insertOnConflictUpdate(_toCompanion(contact));

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.contacts)..where((c) => c.id.equals(id) & _ownedBy(c))).go();

  Contact _toDomain(ContactRow row) => Contact(
        id: row.id,
        source: ContactSource.values.asNameMap()[row.source] ?? ContactSource.manual,
        sourceSlug: row.sourceSlug,
        sourceCardId: row.sourceCardId,
        name: row.name,
        title: row.title,
        company: row.company,
        email: row.email,
        phone: row.phone,
        website: row.website,
        linkedin: row.linkedin,
        location: row.location,
        links: (jsonDecode(row.linksJson) as List)
            .map((e) => CardLink.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: row.notes,
        scannedAt: row.scannedAt,
        profilePending: row.profilePending,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  ContactsCompanion _toCompanion(Contact c) => ContactsCompanion.insert(
        id: c.id,
        ownerId: Value(ownerId),
        source: c.source.name,
        sourceSlug: Value(c.sourceSlug),
        sourceCardId: Value(c.sourceCardId),
        name: c.name,
        title: Value(c.title),
        company: Value(c.company),
        email: Value(c.email),
        phone: Value(c.phone),
        website: Value(c.website),
        linkedin: Value(c.linkedin),
        location: Value(c.location),
        linksJson: Value(jsonEncode(c.links.map((l) => l.toJson()).toList())),
        notes: Value(c.notes),
        scannedAt: Value(c.scannedAt),
        profilePending: Value(c.profilePending),
        createdAt: c.createdAt,
        updatedAt: c.updatedAt,
        pendingSync: const Value(true),
      );
}
