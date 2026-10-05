import 'dart:async';

import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../domain/beacon_id.dart';
import '../domain/nearby_ports.dart';

/// Advertising via flutter_ble_peripheral, scanning via flutter_blue_plus.
class PluginBleRadio implements BleRadio {
  final _peripheral = FlutterBlePeripheral();
  final _sightings = StreamController<Sighting>.broadcast();
  StreamSubscription<List<ScanResult>>? _results;

  @override
  Future<RadioStatus> prepare() async {
    if (!await FlutterBluePlus.isSupported) return RadioStatus.unsupported;
    final permission = await _peripheral.requestPermission();
    if (permission == PeripheralBluetoothState.denied ||
        permission == PeripheralBluetoothState.permanentlyDenied ||
        permission == PeripheralBluetoothState.restricted) {
      return RadioStatus.permissionDenied;
    }
    final adapter = await FlutterBluePlus.adapterState
        .where((s) => s != BluetoothAdapterState.unknown)
        .first
        .timeout(
          const Duration(seconds: 3),
          onTimeout: () => BluetoothAdapterState.unknown,
        );
    return switch (adapter) {
      BluetoothAdapterState.on => RadioStatus.ready,
      BluetoothAdapterState.unauthorized => RadioStatus.permissionDenied,
      BluetoothAdapterState.unavailable => RadioStatus.unsupported,
      _ => RadioStatus.bluetoothOff,
    };
  }

  @override
  Future<bool> canAdvertise() async {
    try {
      return await _peripheral.isSupported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> startAdvertising(String serviceUuid) async {
    await _peripheral.start(
      advertiseData: AdvertiseDataCore(serviceUuid: serviceUuid),
    );
  }

  @override
  Future<void> stopAdvertising() async {
    try {
      await _peripheral.stop();
    } catch (_) {}
  }

  @override
  Future<void> startScan() async {
    await _results?.cancel();
    _results = FlutterBluePlus.onScanResults.listen((results) {
      for (final result in results) {
        for (final uuid in result.advertisementData.serviceUuids) {
          final value = uuid.str128;
          if (value.startsWith(beaconUuidPrefix)) {
            _sightings.add(Sighting(serviceUuid: value, rssi: result.rssi));
          }
        }
      }
    });
    await FlutterBluePlus.startScan(
      continuousUpdates: true,
      removeIfGone: const Duration(seconds: 30),
      // We never derive location from scans (manifest: neverForLocation).
      androidCheckLocationServices: false,
    );
  }

  @override
  Future<void> stopScan() async {
    await _results?.cancel();
    _results = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  @override
  Stream<Sighting> get sightings => _sightings.stream;

  @override
  Future<void> openSettings() async {
    try {
      await _peripheral.openBluetoothSettings();
    } catch (_) {}
  }
}
