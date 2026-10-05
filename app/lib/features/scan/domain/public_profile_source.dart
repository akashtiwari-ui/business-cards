import '../../card/domain/business_card.dart';

/// A live card as the public sees it: hidden phone/email are already empty.
class PublicProfile {
  const PublicProfile({
    required this.cardId,
    required this.slug,
    required this.name,
    this.title = '',
    this.company = '',
    this.email = '',
    this.phone = '',
    this.website = '',
    this.linkedin = '',
    this.location = '',
    this.links = const [],
  });

  final String cardId;
  final String slug;
  final String name;
  final String title;
  final String company;
  final String email;
  final String phone;
  final String website;
  final String linkedin;
  final String location;
  final List<CardLink> links;
}

abstract interface class PublicProfileSource {
  /// The live profile, or null when it is hidden or does not exist.
  /// Throws when the server cannot be reached.
  Future<PublicProfile?> fetchBySlug(String slug);
}
