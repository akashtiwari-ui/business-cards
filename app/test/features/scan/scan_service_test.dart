import 'package:b_card/core/db/app_database.dart';
import 'package:b_card/features/contacts/data/local_contact_repository.dart';
import 'package:b_card/features/scan/application/scan_service.dart';
import 'package:b_card/features/scan/domain/public_profile_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProfiles implements PublicProfileSource {
  final profiles = <String, PublicProfile>{};
  bool offline = false;
  int calls = 0;

  @override
  Future<PublicProfile?> fetchBySlug(String slug) async {
    calls++;
    if (offline) throw Exception('offline');
    return profiles[slug];
  }
}

const _base = 'https://b-cards.vercel.app/p';
const _priyaUrl = '$_base/priya';

void main() {
  late AppDatabase db;
  late LocalContactRepository contacts;
  late FakeProfiles profiles;
  late ScanService service;
  var ids = 0;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    contacts = LocalContactRepository(db, ownerId: 'u1');
    profiles = FakeProfiles()
      ..profiles['priya'] = const PublicProfile(
        cardId: 'card-p',
        slug: 'priya',
        name: 'Priya Shah',
        title: 'Head of Sales',
        company: 'Acme',
        email: 'priya@acme.in',
      );
    service = ScanService(
      contacts: contacts,
      profiles: profiles,
      profileBaseUrl: _base,
      ownSlug: 'akash',
      newId: () => 'c${ids++}',
    );
  });

  tearDown(() => db.close());

  test('a B Card scan is saved straight away with its provenance', () async {
    final outcome = await service.handle(_priyaUrl);

    final saved = (outcome as ContactSaved).contact;
    expect(saved.name, 'Priya Shah');
    expect(saved.sourceSlug, 'priya');
    expect(saved.sourceCardId, 'card-p');
    expect(saved.scannedAt, isNotNull);
    expect(await contacts.watchAll().first, hasLength(1));
  });

  test('scanning the same card twice never creates two contacts', () async {
    await service.handle(_priyaUrl);
    final first = (await contacts.watchAll().first).single;
    await contacts.save(first.copyWith(notes: 'Met at the expo'));

    final outcome = await service.handle(_priyaUrl);

    expect(outcome, isA<AlreadySaved>().having((o) => o.refreshed, 'refreshed', isTrue));
    final all = await contacts.watchAll().first;
    expect(all, hasLength(1));
    expect(all.single.notes, 'Met at the expo', reason: 'user notes survive a refresh');
  });

  test('offline scans are saved as pending and completed later', () async {
    profiles.offline = true;
    final outcome = await service.handle(_priyaUrl);
    expect(outcome, isA<SavedOffline>());
    expect((await contacts.watchAll().first).single.profilePending, isTrue);

    expect(await service.resolvePending(), 0, reason: 'still offline');

    profiles.offline = false;
    expect(await service.resolvePending(), 1);
    final resolved = (await contacts.watchAll().first).single;
    expect(resolved.name, 'Priya Shah');
    expect(resolved.profilePending, isFalse);
  });

  test('hidden profiles are not saved', () async {
    expect(await service.handle('$_base/ghost'), isA<ProfileUnavailable>());
    expect(await contacts.watchAll().first, isEmpty);
  });

  test('your own card is recognised', () async {
    expect(await service.handle('$_base/akash'), isA<OwnCardScanned>());
    expect(profiles.calls, 0);
  });

  test('vCards from other apps are saved, and duplicates matched by email', () async {
    const vcard = 'BEGIN:VCARD\nVERSION:3.0\nFN:Kabir Rao\nEMAIL:kabir@x.in\nTEL:+91 99999 11111\nEND:VCARD';
    expect(await service.handle(vcard), isA<ContactSaved>());
    expect(await service.handle(vcard), isA<AlreadySaved>());
    expect(await contacts.watchAll().first, hasLength(1));
  });

  test('other QR codes are reported, not saved', () async {
    expect(await service.handle('WIFI:S:Office;;'), isA<NotAContactCode>());
    expect(await contacts.watchAll().first, isEmpty);
  });

  test('contacts are private to each user on a shared phone', () async {
    await service.handle(_priyaUrl);
    expect(await LocalContactRepository(db, ownerId: 'u2').watchAll().first, isEmpty);
  });
}
