// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CardsTable extends Cards with TableInfo<$CardsTable, CardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _websiteMeta = const VerificationMeta(
    'website',
  );
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
    'website',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _linkedinMeta = const VerificationMeta(
    'linkedin',
  );
  @override
  late final GeneratedColumn<String> linkedin = GeneratedColumn<String>(
    'linkedin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _linksJsonMeta = const VerificationMeta(
    'linksJson',
  );
  @override
  late final GeneratedColumn<String> linksJson = GeneratedColumn<String>(
    'links_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _hidePhoneMeta = const VerificationMeta(
    'hidePhone',
  );
  @override
  late final GeneratedColumn<bool> hidePhone = GeneratedColumn<bool>(
    'hide_phone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hide_phone" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hideEmailMeta = const VerificationMeta(
    'hideEmail',
  );
  @override
  late final GeneratedColumn<bool> hideEmail = GeneratedColumn<bool>(
    'hide_email',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hide_email" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pendingSyncMeta = const VerificationMeta(
    'pendingSync',
  );
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
    'pending_sync',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending_sync" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    slug,
    name,
    title,
    company,
    phone,
    email,
    website,
    linkedin,
    location,
    bio,
    linksJson,
    isPublic,
    hidePhone,
    hideEmail,
    updatedAt,
    pendingSync,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('website')) {
      context.handle(
        _websiteMeta,
        website.isAcceptableOrUnknown(data['website']!, _websiteMeta),
      );
    }
    if (data.containsKey('linkedin')) {
      context.handle(
        _linkedinMeta,
        linkedin.isAcceptableOrUnknown(data['linkedin']!, _linkedinMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('links_json')) {
      context.handle(
        _linksJsonMeta,
        linksJson.isAcceptableOrUnknown(data['links_json']!, _linksJsonMeta),
      );
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
      );
    }
    if (data.containsKey('hide_phone')) {
      context.handle(
        _hidePhoneMeta,
        hidePhone.isAcceptableOrUnknown(data['hide_phone']!, _hidePhoneMeta),
      );
    }
    if (data.containsKey('hide_email')) {
      context.handle(
        _hideEmailMeta,
        hideEmail.isAcceptableOrUnknown(data['hide_email']!, _hideEmailMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
        _pendingSyncMeta,
        pendingSync.isAcceptableOrUnknown(
          data['pending_sync']!,
          _pendingSyncMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      website: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website'],
      )!,
      linkedin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linkedin'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      )!,
      linksJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}links_json'],
      )!,
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
      hidePhone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_phone'],
      )!,
      hideEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hide_email'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      pendingSync: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending_sync'],
      )!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class CardRow extends DataClass implements Insertable<CardRow> {
  final String id;

  /// Supabase user id; null for cards made in the offline-only build.
  final String? ownerId;
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

  /// JSON array of `{label, url}` objects.
  final String linksJson;
  final bool isPublic;
  final bool hidePhone;
  final bool hideEmail;
  final DateTime updatedAt;

  /// True until the row has been pushed to the backend.
  final bool pendingSync;
  const CardRow({
    required this.id,
    this.ownerId,
    required this.slug,
    required this.name,
    required this.title,
    required this.company,
    required this.phone,
    required this.email,
    required this.website,
    required this.linkedin,
    required this.location,
    required this.bio,
    required this.linksJson,
    required this.isPublic,
    required this.hidePhone,
    required this.hideEmail,
    required this.updatedAt,
    required this.pendingSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['slug'] = Variable<String>(slug);
    map['name'] = Variable<String>(name);
    map['title'] = Variable<String>(title);
    map['company'] = Variable<String>(company);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['website'] = Variable<String>(website);
    map['linkedin'] = Variable<String>(linkedin);
    map['location'] = Variable<String>(location);
    map['bio'] = Variable<String>(bio);
    map['links_json'] = Variable<String>(linksJson);
    map['is_public'] = Variable<bool>(isPublic);
    map['hide_phone'] = Variable<bool>(hidePhone);
    map['hide_email'] = Variable<bool>(hideEmail);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      slug: Value(slug),
      name: Value(name),
      title: Value(title),
      company: Value(company),
      phone: Value(phone),
      email: Value(email),
      website: Value(website),
      linkedin: Value(linkedin),
      location: Value(location),
      bio: Value(bio),
      linksJson: Value(linksJson),
      isPublic: Value(isPublic),
      hidePhone: Value(hidePhone),
      hideEmail: Value(hideEmail),
      updatedAt: Value(updatedAt),
      pendingSync: Value(pendingSync),
    );
  }

  factory CardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardRow(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      slug: serializer.fromJson<String>(json['slug']),
      name: serializer.fromJson<String>(json['name']),
      title: serializer.fromJson<String>(json['title']),
      company: serializer.fromJson<String>(json['company']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      website: serializer.fromJson<String>(json['website']),
      linkedin: serializer.fromJson<String>(json['linkedin']),
      location: serializer.fromJson<String>(json['location']),
      bio: serializer.fromJson<String>(json['bio']),
      linksJson: serializer.fromJson<String>(json['linksJson']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      hidePhone: serializer.fromJson<bool>(json['hidePhone']),
      hideEmail: serializer.fromJson<bool>(json['hideEmail']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String?>(ownerId),
      'slug': serializer.toJson<String>(slug),
      'name': serializer.toJson<String>(name),
      'title': serializer.toJson<String>(title),
      'company': serializer.toJson<String>(company),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'website': serializer.toJson<String>(website),
      'linkedin': serializer.toJson<String>(linkedin),
      'location': serializer.toJson<String>(location),
      'bio': serializer.toJson<String>(bio),
      'linksJson': serializer.toJson<String>(linksJson),
      'isPublic': serializer.toJson<bool>(isPublic),
      'hidePhone': serializer.toJson<bool>(hidePhone),
      'hideEmail': serializer.toJson<bool>(hideEmail),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  CardRow copyWith({
    String? id,
    Value<String?> ownerId = const Value.absent(),
    String? slug,
    String? name,
    String? title,
    String? company,
    String? phone,
    String? email,
    String? website,
    String? linkedin,
    String? location,
    String? bio,
    String? linksJson,
    bool? isPublic,
    bool? hidePhone,
    bool? hideEmail,
    DateTime? updatedAt,
    bool? pendingSync,
  }) => CardRow(
    id: id ?? this.id,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    slug: slug ?? this.slug,
    name: name ?? this.name,
    title: title ?? this.title,
    company: company ?? this.company,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    website: website ?? this.website,
    linkedin: linkedin ?? this.linkedin,
    location: location ?? this.location,
    bio: bio ?? this.bio,
    linksJson: linksJson ?? this.linksJson,
    isPublic: isPublic ?? this.isPublic,
    hidePhone: hidePhone ?? this.hidePhone,
    hideEmail: hideEmail ?? this.hideEmail,
    updatedAt: updatedAt ?? this.updatedAt,
    pendingSync: pendingSync ?? this.pendingSync,
  );
  CardRow copyWithCompanion(CardsCompanion data) {
    return CardRow(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      slug: data.slug.present ? data.slug.value : this.slug,
      name: data.name.present ? data.name.value : this.name,
      title: data.title.present ? data.title.value : this.title,
      company: data.company.present ? data.company.value : this.company,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      website: data.website.present ? data.website.value : this.website,
      linkedin: data.linkedin.present ? data.linkedin.value : this.linkedin,
      location: data.location.present ? data.location.value : this.location,
      bio: data.bio.present ? data.bio.value : this.bio,
      linksJson: data.linksJson.present ? data.linksJson.value : this.linksJson,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      hidePhone: data.hidePhone.present ? data.hidePhone.value : this.hidePhone,
      hideEmail: data.hideEmail.present ? data.hideEmail.value : this.hideEmail,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      pendingSync: data.pendingSync.present
          ? data.pendingSync.value
          : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardRow(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('title: $title, ')
          ..write('company: $company, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('website: $website, ')
          ..write('linkedin: $linkedin, ')
          ..write('location: $location, ')
          ..write('bio: $bio, ')
          ..write('linksJson: $linksJson, ')
          ..write('isPublic: $isPublic, ')
          ..write('hidePhone: $hidePhone, ')
          ..write('hideEmail: $hideEmail, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    slug,
    name,
    title,
    company,
    phone,
    email,
    website,
    linkedin,
    location,
    bio,
    linksJson,
    isPublic,
    hidePhone,
    hideEmail,
    updatedAt,
    pendingSync,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardRow &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.slug == this.slug &&
          other.name == this.name &&
          other.title == this.title &&
          other.company == this.company &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.website == this.website &&
          other.linkedin == this.linkedin &&
          other.location == this.location &&
          other.bio == this.bio &&
          other.linksJson == this.linksJson &&
          other.isPublic == this.isPublic &&
          other.hidePhone == this.hidePhone &&
          other.hideEmail == this.hideEmail &&
          other.updatedAt == this.updatedAt &&
          other.pendingSync == this.pendingSync);
}

class CardsCompanion extends UpdateCompanion<CardRow> {
  final Value<String> id;
  final Value<String?> ownerId;
  final Value<String> slug;
  final Value<String> name;
  final Value<String> title;
  final Value<String> company;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> website;
  final Value<String> linkedin;
  final Value<String> location;
  final Value<String> bio;
  final Value<String> linksJson;
  final Value<bool> isPublic;
  final Value<bool> hidePhone;
  final Value<bool> hideEmail;
  final Value<DateTime> updatedAt;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.slug = const Value.absent(),
    this.name = const Value.absent(),
    this.title = const Value.absent(),
    this.company = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.website = const Value.absent(),
    this.linkedin = const Value.absent(),
    this.location = const Value.absent(),
    this.bio = const Value.absent(),
    this.linksJson = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.hidePhone = const Value.absent(),
    this.hideEmail = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    this.ownerId = const Value.absent(),
    required String slug,
    required String name,
    this.title = const Value.absent(),
    this.company = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.website = const Value.absent(),
    this.linkedin = const Value.absent(),
    this.location = const Value.absent(),
    this.bio = const Value.absent(),
    this.linksJson = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.hidePhone = const Value.absent(),
    this.hideEmail = const Value.absent(),
    required DateTime updatedAt,
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       slug = Value(slug),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<CardRow> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? slug,
    Expression<String>? name,
    Expression<String>? title,
    Expression<String>? company,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? website,
    Expression<String>? linkedin,
    Expression<String>? location,
    Expression<String>? bio,
    Expression<String>? linksJson,
    Expression<bool>? isPublic,
    Expression<bool>? hidePhone,
    Expression<bool>? hideEmail,
    Expression<DateTime>? updatedAt,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (slug != null) 'slug': slug,
      if (name != null) 'name': name,
      if (title != null) 'title': title,
      if (company != null) 'company': company,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (linkedin != null) 'linkedin': linkedin,
      if (location != null) 'location': location,
      if (bio != null) 'bio': bio,
      if (linksJson != null) 'links_json': linksJson,
      if (isPublic != null) 'is_public': isPublic,
      if (hidePhone != null) 'hide_phone': hidePhone,
      if (hideEmail != null) 'hide_email': hideEmail,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerId,
    Value<String>? slug,
    Value<String>? name,
    Value<String>? title,
    Value<String>? company,
    Value<String>? phone,
    Value<String>? email,
    Value<String>? website,
    Value<String>? linkedin,
    Value<String>? location,
    Value<String>? bio,
    Value<String>? linksJson,
    Value<bool>? isPublic,
    Value<bool>? hidePhone,
    Value<bool>? hideEmail,
    Value<DateTime>? updatedAt,
    Value<bool>? pendingSync,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      title: title ?? this.title,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      linksJson: linksJson ?? this.linksJson,
      isPublic: isPublic ?? this.isPublic,
      hidePhone: hidePhone ?? this.hidePhone,
      hideEmail: hideEmail ?? this.hideEmail,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (linkedin.present) {
      map['linkedin'] = Variable<String>(linkedin.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (linksJson.present) {
      map['links_json'] = Variable<String>(linksJson.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (hidePhone.present) {
      map['hide_phone'] = Variable<bool>(hidePhone.value);
    }
    if (hideEmail.present) {
      map['hide_email'] = Variable<bool>(hideEmail.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('title: $title, ')
          ..write('company: $company, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('website: $website, ')
          ..write('linkedin: $linkedin, ')
          ..write('location: $location, ')
          ..write('bio: $bio, ')
          ..write('linksJson: $linksJson, ')
          ..write('isPublic: $isPublic, ')
          ..write('hidePhone: $hidePhone, ')
          ..write('hideEmail: $hideEmail, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CardsTable cards = $CardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cards];
}

typedef $$CardsTableCreateCompanionBuilder =
    CardsCompanion Function({
      required String id,
      Value<String?> ownerId,
      required String slug,
      required String name,
      Value<String> title,
      Value<String> company,
      Value<String> phone,
      Value<String> email,
      Value<String> website,
      Value<String> linkedin,
      Value<String> location,
      Value<String> bio,
      Value<String> linksJson,
      Value<bool> isPublic,
      Value<bool> hidePhone,
      Value<bool> hideEmail,
      required DateTime updatedAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });
typedef $$CardsTableUpdateCompanionBuilder =
    CardsCompanion Function({
      Value<String> id,
      Value<String?> ownerId,
      Value<String> slug,
      Value<String> name,
      Value<String> title,
      Value<String> company,
      Value<String> phone,
      Value<String> email,
      Value<String> website,
      Value<String> linkedin,
      Value<String> location,
      Value<String> bio,
      Value<String> linksJson,
      Value<bool> isPublic,
      Value<bool> hidePhone,
      Value<bool> hideEmail,
      Value<DateTime> updatedAt,
      Value<bool> pendingSync,
      Value<int> rowid,
    });

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedin => $composableBuilder(
    column: $table.linkedin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linksJson => $composableBuilder(
    column: $table.linksJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidePhone => $composableBuilder(
    column: $table.hidePhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hideEmail => $composableBuilder(
    column: $table.hideEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedin => $composableBuilder(
    column: $table.linkedin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linksJson => $composableBuilder(
    column: $table.linksJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidePhone => $composableBuilder(
    column: $table.hidePhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hideEmail => $composableBuilder(
    column: $table.hideEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get linkedin =>
      $composableBuilder(column: $table.linkedin, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get linksJson =>
      $composableBuilder(column: $table.linksJson, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<bool> get hidePhone =>
      $composableBuilder(column: $table.hidePhone, builder: (column) => column);

  GeneratedColumn<bool> get hideEmail =>
      $composableBuilder(column: $table.hideEmail, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
    column: $table.pendingSync,
    builder: (column) => column,
  );
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          CardRow,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (CardRow, BaseReferences<_$AppDatabase, $CardsTable, CardRow>),
          CardRow,
          PrefetchHooks Function()
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> company = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> website = const Value.absent(),
                Value<String> linkedin = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> bio = const Value.absent(),
                Value<String> linksJson = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> hidePhone = const Value.absent(),
                Value<bool> hideEmail = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                ownerId: ownerId,
                slug: slug,
                name: name,
                title: title,
                company: company,
                phone: phone,
                email: email,
                website: website,
                linkedin: linkedin,
                location: location,
                bio: bio,
                linksJson: linksJson,
                isPublic: isPublic,
                hidePhone: hidePhone,
                hideEmail: hideEmail,
                updatedAt: updatedAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerId = const Value.absent(),
                required String slug,
                required String name,
                Value<String> title = const Value.absent(),
                Value<String> company = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> website = const Value.absent(),
                Value<String> linkedin = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> bio = const Value.absent(),
                Value<String> linksJson = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<bool> hidePhone = const Value.absent(),
                Value<bool> hideEmail = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> pendingSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                ownerId: ownerId,
                slug: slug,
                name: name,
                title: title,
                company: company,
                phone: phone,
                email: email,
                website: website,
                linkedin: linkedin,
                location: location,
                bio: bio,
                linksJson: linksJson,
                isPublic: isPublic,
                hidePhone: hidePhone,
                hideEmail: hideEmail,
                updatedAt: updatedAt,
                pendingSync: pendingSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CardsTable, CardRow>(table),
                  BaseReferences<_$AppDatabase, $CardsTable, CardRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      CardRow,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (CardRow, BaseReferences<_$AppDatabase, $CardsTable, CardRow>),
      CardRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
}
