import 'package:flutter/foundation.dart';

@immutable
class CardLink {
  const CardLink({required this.label, required this.url});

  factory CardLink.fromJson(Map<String, dynamic> json) => CardLink(
        label: json['label'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );

  final String label;
  final String url;

  Map<String, dynamic> toJson() => {'label': label, 'url': url};

  @override
  bool operator ==(Object other) =>
      other is CardLink && other.label == label && other.url == url;

  @override
  int get hashCode => Object.hash(label, url);
}

/// The user's own digital business card (PRD 4.2).
///
/// [slug] is permanent: it forms the profile URL encoded in the QR code.
@immutable
class BusinessCard {
  const BusinessCard({
    required this.id,
    required this.slug,
    required this.name,
    required this.updatedAt,
    this.title = '',
    this.company = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.linkedin = '',
    this.location = '',
    this.bio = '',
    this.links = const [],
    this.isPublic = true,
    this.hidePhone = false,
    this.hideEmail = false,
    this.syncPending = false,
  });

  final String id;
  final String slug;
  final String name;
  final String title;
  final String company;
  final String phone;
  final String email;
  final String website;
  final String linkedin;
  final String location;
  final String bio;
  final List<CardLink> links;
  final bool isPublic;
  final bool hidePhone;
  final bool hideEmail;
  final DateTime updatedAt;

  /// True while local edits have not reached the server yet.
  final bool syncPending;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  /// "Title · Company", skipping whichever is empty.
  String get headline =>
      [title, company].where((s) => s.isNotEmpty).join(' · ');

  BusinessCard copyWith({
    String? name,
    String? title,
    String? company,
    String? phone,
    String? email,
    String? website,
    String? linkedin,
    String? location,
    String? bio,
    List<CardLink>? links,
    bool? isPublic,
    bool? hidePhone,
    bool? hideEmail,
    DateTime? updatedAt,
  }) =>
      BusinessCard(
        id: id,
        slug: slug,
        name: name ?? this.name,
        title: title ?? this.title,
        company: company ?? this.company,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        website: website ?? this.website,
        linkedin: linkedin ?? this.linkedin,
        location: location ?? this.location,
        bio: bio ?? this.bio,
        links: links ?? this.links,
        isPublic: isPublic ?? this.isPublic,
        hidePhone: hidePhone ?? this.hidePhone,
        hideEmail: hideEmail ?? this.hideEmail,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
