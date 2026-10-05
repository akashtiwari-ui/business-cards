/// Boundaries of the Nearby feature: the Bluetooth radio and the server that
/// turns beacon tokens into public profiles.
library;

enum RadioStatus { ready, bluetoothOff, permissionDenied, unsupported }

/// One BLE advertisement heard nearby.
class Sighting {
  const Sighting({required this.serviceUuid, required this.rssi});

  final String serviceUuid;
  final int rssi;
}

abstract interface class BleRadio {
  /// Asks for Bluetooth permissions and checks the adapter.
  Future<RadioStatus> prepare();

  /// Whether this phone can advertise (some Android phones can only scan).
  Future<bool> canAdvertise();

  Future<void> startAdvertising(String serviceUuid);

  Future<void> stopAdvertising();

  /// Starts scanning; sightings arrive on [sightings] until [stopScan].
  Future<void> startScan();

  Future<void> stopScan();

  Stream<Sighting> get sightings;

  Future<void> openSettings();
}

/// Public fields of a card behind a beacon token.
class NearbyProfile {
  const NearbyProfile({
    required this.token,
    required this.cardId,
    required this.slug,
    required this.name,
    this.title = '',
    this.company = '',
  });

  final String token;
  final String cardId;
  final String slug;
  final String name;
  final String title;
  final String company;

  String get headline =>
      [title, company].where((s) => s.isNotEmpty).join(' · ');
}

abstract interface class BeaconRegistry {
  /// Makes [token] point at [cardId] until [expiresAt], retiring older tokens.
  Future<void> register({
    required String cardId,
    required String token,
    required DateTime expiresAt,
  });

  /// Live, public profiles for the tokens that have one.
  Future<List<NearbyProfile>> resolve(List<String> tokens);
}
