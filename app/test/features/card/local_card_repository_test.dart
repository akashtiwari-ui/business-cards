import 'package:b_card/core/db/app_database.dart';
import 'package:b_card/features/card/data/local_card_repository.dart';
import 'package:b_card/features/card/domain/business_card.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late LocalCardRepository repo;

  final card = BusinessCard(
    id: 'card-1',
    slug: 'aarav',
    name: 'Aarav Shah',
    title: 'Founder',
    company: 'Acme',
    email: 'aarav@acme.in',
    links: const [CardLink(label: 'Portfolio', url: 'https://acme.in/work')],
    hidePhone: true,
    updatedAt: DateTime(2026, 10, 5),
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = LocalCardRepository(db);
  });

  tearDown(() => db.close());

  test('emits null before a card exists', () async {
    expect(await repo.watchMyCard().first, isNull);
  });

  test('round-trips every field, including links', () async {
    await repo.save(card);
    final saved = await repo.watchMyCard().first;

    expect(saved!.slug, 'aarav');
    expect(saved.headline, 'Founder · Acme');
    expect(saved.links, card.links);
    expect(saved.hidePhone, isTrue);
    expect(saved.isPublic, isTrue);
  });

  test('saving again updates in place instead of adding a row', () async {
    await repo.save(card);
    await repo.save(card.copyWith(title: 'CEO'));

    final rows = await db.select(db.cards).get();
    expect(rows, hasLength(1));
    expect(rows.single.title, 'CEO');
  });

  test('setVisibility toggles the public flag and marks it for sync', () async {
    await repo.save(card);
    await (db.update(db.cards)).write(const CardsCompanion(pendingSync: Value(false)));

    await repo.setVisibility('card-1', isPublic: false);

    final row = await db.select(db.cards).getSingle();
    expect(row.isPublic, isFalse);
    expect(row.pendingSync, isTrue);
  });
}
