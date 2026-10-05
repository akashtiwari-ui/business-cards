import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../contacts/domain/contact.dart';
import '../../contacts/domain/contact_repository.dart';
import '../domain/public_profile_source.dart';
import '../domain/scan_parser.dart';

/// Result of handling one scanned code; drives the sheet the user sees.
sealed class ScanOutcome {
  const ScanOutcome();
}

/// New contact saved straight away (auto-save, PRD 4.4).
class ContactSaved extends ScanOutcome {
  const ContactSaved(this.contact);

  final Contact contact;
}

/// The same person was already saved; their details were refreshed instead
/// of creating a second entry.
class AlreadySaved extends ScanOutcome {
  const AlreadySaved(this.contact, {required this.refreshed});

  final Contact contact;
  final bool refreshed;
}

/// No network: saved as pending, completed when back online.
class SavedOffline extends ScanOutcome {
  const SavedOffline(this.contact);

  final Contact contact;
}

class ProfileUnavailable extends ScanOutcome {
  const ProfileUnavailable();
}

class OwnCardScanned extends ScanOutcome {
  const OwnCardScanned();
}

class NotAContactCode extends ScanOutcome {
  const NotAContactCode(this.text);

  final String text;
}

class ScanService {
  ScanService({
    required this.contacts,
    required this.profiles,
    required this.profileBaseUrl,
    this.ownSlug,
    DateTime Function()? clock,
    String Function()? newId,
  })  : _now = clock ?? DateTime.now,
        _newId = newId ?? (() => const Uuid().v4());

  final ContactRepository contacts;

  /// Null in the offline-only build: every B Card scan is saved as pending.
  final PublicProfileSource? profiles;
  final String profileBaseUrl;
  final String? ownSlug;
  final DateTime Function() _now;
  final String Function() _newId;

  Future<ScanOutcome> handle(String raw) async {
    return switch (parseScan(raw, profileBaseUrl: profileBaseUrl)) {
      BCardLink(:final slug) => _handleBCard(slug, ContactSource.qr),
      final ContactDetails details => _handleDetails(details),
      NotAContact(:final text) => NotAContactCode(text),
    };
  }

  /// Saves someone found in Nearby (Beacon mode) the same way as a QR scan.
  Future<ScanOutcome> saveNearby(String slug) => _handleBCard(slug, ContactSource.nearby);

  Future<ScanOutcome> _handleBCard(String slug, ContactSource source) async {
    if (slug == ownSlug) return const OwnCardScanned();
    final existing = await contacts.findBySlug(slug);

    final PublicProfile? profile;
    try {
      profile = await profiles?.fetchBySlug(slug);
      if (profiles == null) throw StateError('offline build');
    } catch (e) {
      debugPrint('Profile fetch deferred: $e');
      if (existing != null) return AlreadySaved(existing, refreshed: false);
      final pending = Contact(
        id: _newId(),
        source: source,
        sourceSlug: slug,
        name: slug,
        scannedAt: _now(),
        profilePending: true,
        createdAt: _now(),
        updatedAt: _now(),
      );
      await contacts.save(pending);
      return SavedOffline(pending);
    }

    if (profile == null) {
      return existing != null ? AlreadySaved(existing, refreshed: false) : const ProfileUnavailable();
    }

    final contact = _applyProfile(
      existing ??
          Contact(
            id: _newId(),
            source: source,
            sourceSlug: slug,
            name: profile.name,
            scannedAt: _now(),
            createdAt: _now(),
            updatedAt: _now(),
          ),
      profile,
    );
    await contacts.save(contact);
    return existing != null ? AlreadySaved(contact, refreshed: true) : ContactSaved(contact);
  }

  Future<ScanOutcome> _handleDetails(ContactDetails d) async {
    final existing = await contacts.findByEmailOrPhone(email: d.email, phone: d.phone);
    if (existing != null) return AlreadySaved(existing, refreshed: false);

    final contact = Contact(
      id: _newId(),
      source: ContactSource.vcard,
      name: d.name,
      title: d.title,
      company: d.company,
      email: d.email,
      phone: d.phone,
      website: d.website,
      location: d.location,
      notes: d.notes,
      scannedAt: _now(),
      createdAt: _now(),
      updatedAt: _now(),
    );
    await contacts.save(contact);
    return ContactSaved(contact);
  }

  /// Completes contacts scanned while offline. Safe to call often.
  Future<int> resolvePending() async {
    final source = profiles;
    if (source == null) return 0;
    var resolved = 0;
    for (final contact in await contacts.pendingProfiles()) {
      final slug = contact.sourceSlug;
      if (slug == null) continue;
      try {
        final profile = await source.fetchBySlug(slug);
        await contacts.save(profile == null
            ? contact.copyWith(profilePending: false, notes: _appendNote(contact.notes, 'Profile unavailable when scanned.'))
            : _applyProfile(contact, profile));
        resolved++;
      } catch (_) {
        return resolved; // Still offline; try again later.
      }
    }
    return resolved;
  }

  /// Refreshes card fields; notes and tags belong to the user and are kept.
  Contact _applyProfile(Contact contact, PublicProfile p) => contact.copyWith(
        sourceCardId: p.cardId,
        name: p.name,
        title: p.title,
        company: p.company,
        email: p.email,
        phone: p.phone,
        website: p.website,
        linkedin: p.linkedin,
        location: p.location,
        links: p.links,
        profilePending: false,
        updatedAt: _now(),
      );

  String _appendNote(String notes, String line) => notes.isEmpty ? line : '$notes\n$line';
}
