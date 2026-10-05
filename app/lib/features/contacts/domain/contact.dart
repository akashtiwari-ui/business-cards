import 'package:flutter/foundation.dart';

import '../../card/domain/business_card.dart';

enum ContactSource { qr, vcard, manual, nfc, nearby }

/// Someone the user met (PRD 4.5, 5.2). A contact scanned from a B Card keeps
/// a copy of the card's fields at scan time plus [sourceSlug], so later card
/// edits can be offered as an update rather than silently changing it.
@immutable
class Contact {
  const Contact({
    required this.id,
    required this.source,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.sourceSlug,
    this.sourceCardId,
    this.title = '',
    this.company = '',
    this.email = '',
    this.phone = '',
    this.website = '',
    this.linkedin = '',
    this.location = '',
    this.links = const [],
    this.notes = '',
    this.scannedAt,
    this.profilePending = false,
  });

  final String id;
  final ContactSource source;
  final String? sourceSlug;
  final String? sourceCardId;
  final String name;
  final String title;
  final String company;
  final String email;
  final String phone;
  final String website;
  final String linkedin;
  final String location;
  final List<CardLink> links;
  final String notes;
  final DateTime? scannedAt;
  final bool profilePending;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get headline => [title, company].where((s) => s.isNotEmpty).join(' · ');

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  /// Text matched by Contacts search (PRD 4.5).
  String get searchText => [name, company, title, email, phone, notes, location].join(' ').toLowerCase();

  Contact copyWith({
    String? sourceCardId,
    String? name,
    String? title,
    String? company,
    String? email,
    String? phone,
    String? website,
    String? linkedin,
    String? location,
    List<CardLink>? links,
    String? notes,
    DateTime? scannedAt,
    bool? profilePending,
    DateTime? updatedAt,
  }) =>
      Contact(
        id: id,
        source: source,
        sourceSlug: sourceSlug,
        sourceCardId: sourceCardId ?? this.sourceCardId,
        name: name ?? this.name,
        title: title ?? this.title,
        company: company ?? this.company,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        website: website ?? this.website,
        linkedin: linkedin ?? this.linkedin,
        location: location ?? this.location,
        links: links ?? this.links,
        notes: notes ?? this.notes,
        scannedAt: scannedAt ?? this.scannedAt,
        profilePending: profilePending ?? this.profilePending,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
