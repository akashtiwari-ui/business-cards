/// Beacon mode identifiers. A phone advertises one 128-bit BLE service UUID:
/// a fixed B Card prefix followed by an 8-byte random token. Service UUIDs are
/// the only payload iPhones may advertise, so this works on both platforms.
library;

import 'dart:math';

/// First 8 bytes of every B Card beacon UUID.
const beaconUuidPrefix = 'b5ca4d00-1e4c-4b1a';

final _token = RegExp(r'^[0-9a-f]{16}$');

/// A fresh random token (16 lowercase hex characters).
String newBeaconToken([Random? random]) {
  final rng = random ?? Random.secure();
  return List.generate(
    8,
    (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

/// `b5ca4d00-1e4c-4b1a-XXXX-XXXXXXXXXXXX` for [token].
String beaconUuid(String token) {
  assert(_token.hasMatch(token));
  return '$beaconUuidPrefix-${token.substring(0, 4)}-${token.substring(4)}';
}

/// The token inside a scanned service UUID, or null if it is not a B Card beacon.
String? beaconTokenFrom(String uuid) {
  final value = uuid.toLowerCase();
  if (!value.startsWith('$beaconUuidPrefix-')) return null;
  final token = value
      .substring(beaconUuidPrefix.length + 1)
      .replaceAll('-', '');
  return _token.hasMatch(token) ? token : null;
}

enum Proximity { veryClose, nearby, inTheRoom }

/// Rough distance from signal strength; good enough to sort a list.
Proximity proximityFor(int rssi) => rssi >= -60
    ? Proximity.veryClose
    : rssi >= -75
    ? Proximity.nearby
    : Proximity.inTheRoom;
