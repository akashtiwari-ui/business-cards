import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../auth/application/auth_providers.dart';
import '../../card/application/card_providers.dart';
import '../../contacts/application/contact_providers.dart';
import '../../scan/application/scan_providers.dart';
import '../../scan/application/scan_service.dart';
import '../data/plugin_ble_radio.dart';
import '../data/supabase_beacon_registry.dart';
import '../domain/beacon_id.dart';
import '../domain/nearby_ports.dart';

final bleRadioProvider = Provider<BleRadio>((ref) => PluginBleRadio());

/// Null in the offline-only build: Nearby needs an account.
final beaconRegistryProvider = Provider<BeaconRegistry?>(
  (ref) => ref.watch(authRequiredProvider)
      ? SupabaseBeaconRegistry(Supabase.instance.client)
      : null,
);

/// How long a broadcast token stays valid.
const beaconTokenLifetime = Duration(hours: 4);

/// People drop off the list when not heard from for this long.
const _staleAfter = Duration(seconds: 45);

enum NearbyStatus {
  idle,
  starting,
  active,
  bluetoothOff,
  permissionDenied,
  unsupported,
  needsAccount,
}

/// Why this phone is not visible to others while Nearby is active.
enum NotVisibleReason { noCard, hidden, cannotAdvertise, offline }

class NearbyPerson {
  const NearbyPerson({
    required this.profile,
    required this.rssi,
    required this.saved,
  });

  final NearbyProfile profile;
  final int rssi;
  final bool saved;

  Proximity get proximity => proximityFor(rssi);
}

@immutable
class NearbyState {
  const NearbyState({
    this.status = NearbyStatus.idle,
    this.visible = false,
    this.notVisibleReason,
    this.people = const [],
    this.unresolvedNearby = 0,
    this.lookupFailing = false,
  });

  final NearbyStatus status;

  /// This phone is broadcasting.
  final bool visible;
  final NotVisibleReason? notVisibleReason;

  /// Resolved people, closest first.
  final List<NearbyPerson> people;

  /// Beacons heard but not (yet) matched to a live profile.
  final int unresolvedNearby;
  final bool lookupFailing;

  NearbyState copyWith({
    NearbyStatus? status,
    bool? visible,
    NotVisibleReason? notVisibleReason,
    bool clearReason = false,
    List<NearbyPerson>? people,
    int? unresolvedNearby,
    bool? lookupFailing,
  }) => NearbyState(
    status: status ?? this.status,
    visible: visible ?? this.visible,
    notVisibleReason: clearReason
        ? null
        : notVisibleReason ?? this.notVisibleReason,
    people: people ?? this.people,
    unresolvedNearby: unresolvedNearby ?? this.unresolvedNearby,
    lookupFailing: lookupFailing ?? this.lookupFailing,
  );
}

/// Beacon mode: broadcast our token and list B Card users around us. Lives
/// only while the Nearby screen watches it (auto-dispose stops the radio).
class NearbyController extends Notifier<NearbyState> {
  StreamSubscription<Sighting>? _sightings;
  Timer? _resolveDebounce;
  Timer? _prune;
  String? _ownToken;
  final _heard = <String, ({int rssi, DateTime at})>{};
  final _profiles =
      <String, NearbyProfile?>{}; // null: no live profile behind token
  final _saved = <String>{};

  // Kept here so shutdown in onDispose never touches the disposed ref.
  late BleRadio _radio;
  String? _ownSlug;

  @override
  NearbyState build() {
    _radio = ref.watch(bleRadioProvider);
    ref.onDispose(_stop);
    return const NearbyState();
  }

  Future<void> start() async {
    final registry = ref.read(beaconRegistryProvider);
    if (registry == null) {
      state = state.copyWith(status: NearbyStatus.needsAccount);
      return;
    }
    state = state.copyWith(status: NearbyStatus.starting);

    final status = await _radio.prepare();
    if (!ref.mounted) return;
    if (status != RadioStatus.ready) {
      state = state.copyWith(
        status: switch (status) {
          RadioStatus.bluetoothOff => NearbyStatus.bluetoothOff,
          RadioStatus.permissionDenied => NearbyStatus.permissionDenied,
          _ => NearbyStatus.unsupported,
        },
      );
      return;
    }

    final reason = await _startBroadcast(registry);
    if (!ref.mounted) return;

    _sightings = _radio.sightings.listen(_onSighting);
    await _radio.startScan();
    _prune = Timer.periodic(const Duration(seconds: 5), (_) => _publish());
    if (!ref.mounted) return;
    state = state.copyWith(
      status: NearbyStatus.active,
      visible: reason == null,
      notVisibleReason: reason,
      clearReason: reason == null,
    );
  }

  /// Returns why we are not visible, or null when broadcasting.
  Future<NotVisibleReason?> _startBroadcast(BeaconRegistry registry) async {
    final card = await ref.read(cardRepositoryProvider).watchMyCard().first;
    _ownSlug = card?.slug;
    if (card == null) return NotVisibleReason.noCard;
    if (!card.isPublic) return NotVisibleReason.hidden;
    if (!await _radio.canAdvertise()) return NotVisibleReason.cannotAdvertise;

    final token = newBeaconToken();
    try {
      await registry.register(
        cardId: card.id,
        token: token,
        expiresAt: DateTime.now().add(beaconTokenLifetime),
      );
      await _radio.startAdvertising(beaconUuid(token));
      _ownToken = token;
      return null;
    } catch (e) {
      debugPrint('Beacon broadcast unavailable: $e');
      return NotVisibleReason.offline;
    }
  }

  void _onSighting(Sighting sighting) {
    final token = beaconTokenFrom(sighting.serviceUuid);
    if (token == null || token == _ownToken) return;
    _heard[token] = (rssi: sighting.rssi, at: DateTime.now());
    if (!_profiles.containsKey(token)) {
      _resolveDebounce?.cancel();
      _resolveDebounce = Timer(const Duration(milliseconds: 600), _resolve);
    }
    _publish();
  }

  Future<void> _resolve() async {
    final registry = ref.read(beaconRegistryProvider);
    final pending = _heard.keys
        .where((t) => !_profiles.containsKey(t))
        .toList();
    if (registry == null || pending.isEmpty) return;
    try {
      final found = {
        for (final p in await registry.resolve(pending)) p.token: p,
      };
      final contacts = ref.read(contactRepositoryProvider);
      for (final token in pending) {
        final profile = found[token];
        _profiles[token] = profile;
        if (profile != null && await contacts.findBySlug(profile.slug) != null) {
          _saved.add(profile.slug);
        }
      }
      if (!ref.mounted) return;
      state = state.copyWith(lookupFailing: false);
    } catch (e) {
      debugPrint('Beacon lookup failed: $e');
      if (ref.mounted) state = state.copyWith(lookupFailing: true);
    }
    if (ref.mounted) _publish();
  }

  void _publish() {
    if (!ref.mounted) return;
    final cutoff = DateTime.now().subtract(_staleAfter);
    _heard.removeWhere((_, h) => h.at.isBefore(cutoff));

    final people = <NearbyPerson>[];
    var unresolved = 0;
    for (final MapEntry(key: token, value: heard) in _heard.entries) {
      final profile = _profiles[token];
      if (profile == null) {
        if (!_profiles.containsKey(token)) unresolved++;
        continue;
      }
      if (profile.slug == _ownSlug) continue;
      people.add(
        NearbyPerson(
          profile: profile,
          rssi: heard.rssi,
          saved: _saved.contains(profile.slug),
        ),
      );
    }
    people.sort((a, b) => b.rssi.compareTo(a.rssi));
    state = state.copyWith(people: people, unresolvedNearby: unresolved);
  }

  /// Saves [person] as a contact (no duplicates, notes kept).
  Future<ScanOutcome> save(NearbyPerson person) async {
    final outcome = await ref
        .read(scanServiceProvider)
        .saveNearby(person.profile.slug);
    if (outcome is ContactSaved ||
        outcome is AlreadySaved ||
        outcome is SavedOffline) {
      _saved.add(person.profile.slug);
      _publish();
    }
    return outcome;
  }

  Future<void> retry() async {
    await _stop();
    _profiles.clear();
    if (ref.mounted) await start();
  }

  Future<void> openSettings() => _radio.openSettings();

  Future<void> _stop() async {
    _resolveDebounce?.cancel();
    _prune?.cancel();
    await _sightings?.cancel();
    _sightings = null;
    _ownToken = null;
    await _radio.stopScan();
    await _radio.stopAdvertising();
  }
}

final nearbyControllerProvider =
    NotifierProvider.autoDispose<NearbyController, NearbyState>(
      NearbyController.new,
    );
