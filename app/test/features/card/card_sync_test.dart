import 'package:b_card/core/db/app_database.dart';
import 'package:b_card/features/card/application/card_sync.dart';
import 'package:b_card/features/card/data/local_card_repository.dart';
import 'package:b_card/features/card/domain/business_card.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  late AppDatabase db;
  late LocalCardRepository local;
  late FakeCardRemote remote;
  late CardSync sync;

  BusinessCard card({String title = 'Founder', DateTime? at}) => BusinessCard(
        id: 'card-1',
        slug: 'aarav',
        name: 'Aarav Shah',
        title: title,
        updatedAt: at ?? DateTime(2026, 10, 5, 10),
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = LocalCardRepository(db, ownerId: 'u1');
    remote = FakeCardRemote();
    sync = CardSync(local: local, remote: remote, userId: 'u1');
  });

  tearDown(() async {
    sync.dispose();
    await db.close();
  });

  test('pushes a pending local card and marks it synced', () async {
    await local.save(card());
    await sync.syncNow();

    expect(remote.cards['u1']!.slug, 'aarav');
    expect((await local.watchMyCard().first)!.syncPending, isFalse);
  });

  test('pulls the server card onto a fresh phone', () async {
    remote.cards['u1'] = card(title: 'CEO');
    await sync.syncNow();

    final pulled = await local.watchMyCard().first;
    expect(pulled!.title, 'CEO');
    expect(pulled.syncPending, isFalse);
  });

  test('offline edits stay pending and are pushed once back online', () async {
    remote.offline = true;
    await local.save(card(title: 'CTO'));
    await sync.syncNow();
    expect((await local.watchMyCard().first)!.syncPending, isTrue);

    remote.offline = false;
    await sync.syncNow();
    expect(remote.cards['u1']!.title, 'CTO');
    expect((await local.watchMyCard().first)!.syncPending, isFalse);
  });

  test('the server copy never overwrites unsynced local edits', () async {
    remote.cards['u1'] = card(title: 'Old title');
    await local.save(card(title: 'New title'));

    await local.saveFromRemote(remote.cards['u1']!);

    expect((await local.watchMyCard().first)!.title, 'New title');
  });

  test('edits made during a push stay pending', () async {
    await local.save(card(at: DateTime(2026, 10, 5, 10)));
    final pushed = await local.watchMyCard().first;
    await local.save(card(title: 'Edited', at: DateTime(2026, 10, 5, 11)));

    await local.markSynced(pushed!.id, pushed.updatedAt);

    expect((await local.watchMyCard().first)!.syncPending, isTrue);
  });

  test('each user only sees their own card on a shared phone', () async {
    await local.save(card());
    final otherUser = LocalCardRepository(db, ownerId: 'u2');

    expect(await otherUser.watchMyCard().first, isNull);
  });

  test('start() syncs right away and again after each edit', () async {
    sync.start();
    await local.save(card());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sync.syncNow();

    expect(remote.cards['u1'], isNotNull);
    expect((await local.watchMyCard().first)!.syncPending, isFalse);
  });
}
