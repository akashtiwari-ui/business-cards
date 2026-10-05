import 'dart:math';

import 'package:b_card/features/nearby/domain/beacon_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tokens are 16 random hex characters', () {
    final token = newBeaconToken(Random(1));
    expect(token, matches(RegExp(r'^[0-9a-f]{16}$')));
    expect(newBeaconToken(), isNot(newBeaconToken()));
  });

  test('token round-trips through a 128-bit service UUID', () {
    const token = '0123456789abcdef';
    final uuid = beaconUuid(token);
    expect(uuid, 'b5ca4d00-1e4c-4b1a-0123-456789abcdef');
    expect(uuid.replaceAll('-', '').length, 32);
    expect(beaconTokenFrom(uuid), token);
    expect(beaconTokenFrom(uuid.toUpperCase()), token);
  });

  test('other service UUIDs are ignored', () {
    expect(beaconTokenFrom('0000180f-0000-1000-8000-00805f9b34fb'), isNull);
    expect(beaconTokenFrom('b5ca4d00-1e4c-4b1a-zzzz-456789abcdef'), isNull);
  });

  test('signal strength maps to rough distance', () {
    expect(proximityFor(-50), Proximity.veryClose);
    expect(proximityFor(-70), Proximity.nearby);
    expect(proximityFor(-90), Proximity.inTheRoom);
  });
}
