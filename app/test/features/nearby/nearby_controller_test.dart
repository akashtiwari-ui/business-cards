import 'dart:async';

import 'package:b_card/core/db/app_database.dart';
import 'package:b_card/features/auth/application/auth_providers.dart';
import 'package:b_card/features/card/application/card_providers.dart';
import 'package:b_card/features/card/domain/business_card.dart';
import 'package:b_card/features/contacts/application/contact_providers.dart';
import 'package:b_card/features/contacts/data/local_contact_repository.dart';
import 'package:b_card/features/nearby/application/nearby_controller.dart';
import 'package:b_card/features/nearby/domain/beacon_id.dart';
import 'package:b_card/features/nearby/domain/nearby_ports.dart';
import 'package:b_card/features/scan/application/scan_providers.dart';
import 'package:b_card/features/scan/domain/public_profile_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

class FakeRadio implements BleRadio {
  RadioStatus status = RadioStatus.ready;
  bool advertisingSupported = true;
  String? advertising;
  bool scanning = false;
  final _sightings = StreamController<Sighting>.broadcast();

  void hear(String token, int rssi) => _sightings.add(Sighting(serviceUuid: beaconUuid(token), rssi: rssi));

  @override
  Future<RadioStatus> prepare() async => status;
  @override
  Future<bool> canAdvertise() async => advertisingSupported;
  @override
  Future<void> startAdvertising(String serviceUuid) async => advertising = serviceUuid;
  @override
  Future<void> stopAdvertising() async => advertising = null;
  @override
  Future<void> startScan() async => scanning = true;
  @override
  Future<void> stopScan() async => scanning = false;
  @override
  Stream<Sighting> get sightings => _sightings.stream;
  @override
  Future<void> openSettings() async {}
}

class FakeRegistry implements BeaconRegistry {
  final registered = <String, String>{}; // token -> card id
  final profiles = <String, NearbyProfile>{};
  bool offline = false;

  @override
  Future<void> register({required String cardId, required String token, required DateTime expiresAt}) async {
    if (offline) throw Exception('offline');
    registered[token] = cardId;
  }

  @override
  Future<List<NearbyProfile>> resolve(List<String> tokens) async {
    if (offline) throw Exception('offline');
    return [for (final t in tokens) ?profiles[t]];
  }
}

class ProfilesFromRegistry implements PublicProfileSource {
  @override
  Future<PublicProfile?> fetchBySlug(String slug) async =>
      PublicProfile(cardId: 'card-$slug', slug: slug, name: slug == 'priya' ? 'Priya Shah' : slug);
}

const _priyaToken = '00112233445566aa';
const _priya = NearbyProfile(token: _priyaToken, cardId: 'card-priya', slug: 'priya', name: 'Priya Shah', company: 'Acme');

void main() {
  late AppDatabase db;
  late FakeRadio radio;
  late FakeRegistry registry;
  late ProviderContainer container;

  ProviderContainer build({BusinessCard? card}) => ProviderContainer(overrides: [
        authRequiredProvider.overrideWithValue(true),
        cardRepositoryProvider.overrideWithValue(FakeCardRepository(card)),
        contactRepositoryProvider.overrideWithValue(LocalContactRepository(db)),
        publicProfileSourceProvider.overrideWithValue(ProfilesFromRegistry()),
        bleRadioProvider.overrideWithValue(radio),
        beaconRegistryProvider.overrideWithValue(registry),
      ]);

  final myCard = BusinessCard(id: 'card-me', slug: 'akash', name: 'Akash', updatedAt: DateTime(2026));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    radio = FakeRadio();
    registry = FakeRegistry()..profiles[_priyaToken] = _priya;
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<NearbyController> started({BusinessCard? card}) async {
    container = build(card: card);
    final sub = container.listen(nearbyControllerProvider, (_, _) {});
    addTearDown(sub.close);
    final controller = container.read(nearbyControllerProvider.notifier);
    await controller.start();
    return controller;
  }

  test('broadcasts a registered token for a public card and scans', () async {
    await started(card: myCard);
    final state = container.read(nearbyControllerProvider);

    expect(state.status, NearbyStatus.active);
    expect(state.visible, isTrue);
    expect(radio.scanning, isTrue);
    final token = registry.registered.keys.single;
    expect(registry.registered[token], 'card-me');
    expect(radio.advertising, beaconUuid(token));
  });

  test('hidden profiles never broadcast but still see others', () async {
    await started(card: myCard.copyWith(isPublic: false));
    final state = container.read(nearbyControllerProvider);

    expect(state.visible, isFalse);
    expect(state.notVisibleReason, NotVisibleReason.hidden);
    expect(radio.advertising, isNull);
    expect(radio.scanning, isTrue);
  });

  test('heard beacons are resolved, listed closest first, and can be saved once', () async {
    registry.profiles['99887766554433bb'] =
        const NearbyProfile(token: '99887766554433bb', cardId: 'card-k', slug: 'kabir', name: 'Kabir');
    final controller = await started(card: myCard);

    radio.hear(_priyaToken, -80);
    radio.hear('99887766554433bb', -55);
    radio.hear('ffffffffffffffff', -40); // unknown or expired token
    await Future<void>.delayed(const Duration(milliseconds: 800));

    var people = container.read(nearbyControllerProvider).people;
    expect(people.map((p) => p.profile.name), ['Kabir', 'Priya Shah']);
    expect(people.first.proximity, Proximity.veryClose);

    await controller.save(people.last);
    await controller.save(people.last);
    people = container.read(nearbyControllerProvider).people;
    expect(people.last.saved, isTrue);

    final contacts = await LocalContactRepository(db).watchAll().first;
    expect(contacts, hasLength(1));
    expect(contacts.single.name, 'Priya Shah');
    expect(contacts.single.source.name, 'nearby');
  });

  test('our own beacon is never listed', () async {
    await started(card: myCard);
    final ownToken = registry.registered.keys.single;
    registry.profiles[ownToken] = NearbyProfile(token: ownToken, cardId: 'card-me', slug: 'akash', name: 'Akash');

    radio.hear(ownToken, -30);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    expect(container.read(nearbyControllerProvider).people, isEmpty);
  });

  test('offline: not visible, and lookups report the problem', () async {
    registry.offline = true;
    await started(card: myCard);
    expect(container.read(nearbyControllerProvider).notVisibleReason, NotVisibleReason.offline);

    radio.hear(_priyaToken, -60);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    expect(container.read(nearbyControllerProvider).lookupFailing, isTrue);
  });

  test('Bluetooth off is reported and nothing starts', () async {
    radio.status = RadioStatus.bluetoothOff;
    await started(card: myCard);
    expect(container.read(nearbyControllerProvider).status, NearbyStatus.bluetoothOff);
    expect(radio.scanning, isFalse);
    expect(registry.registered, isEmpty);
  });

  test('leaving Nearby stops the radio', () async {
    await started(card: myCard);
    container.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(radio.scanning, isFalse);
    expect(radio.advertising, isNull);
    container = build(); // for tearDown
  });
}
