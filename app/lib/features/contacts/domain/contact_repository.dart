import 'contact.dart';

/// Saved contacts, stored on the phone first (PRD 5.1: fully usable offline).
abstract interface class ContactRepository {
  /// Newest first.
  Stream<List<Contact>> watchAll();

  Stream<Contact?> watch(String id);

  Future<Contact?> findBySlug(String slug);

  /// Matches on email or phone, for vCard duplicate detection.
  Future<Contact?> findByEmailOrPhone({required String email, required String phone});

  Future<List<Contact>> pendingProfiles();

  Future<void> save(Contact contact);

  Future<void> delete(String id);
}
