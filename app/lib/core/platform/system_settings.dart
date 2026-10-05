import 'package:flutter/services.dart';

const _channel = MethodChannel('com.bcard/system');

/// Opens this app's page in the system settings, e.g. to re-enable the camera.
Future<void> openAppSettings() async {
  try {
    await _channel.invokeMethod<void>('openAppSettings');
  } on MissingPluginException {
    // iOS and tests: nothing to open.
  }
}
