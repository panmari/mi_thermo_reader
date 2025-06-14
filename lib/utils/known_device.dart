import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_thermo_reader/main.dart';
import 'package:mi_thermo_reader/utils/sensor_history.dart';
import 'package:proto_annotations/proto_annotations.dart';
import 'package:protobuf/protobuf.dart';
import 'package:mi_thermo_reader/src/proto/model.pb.dart';

part 'known_device.g.dart';

// After changing this file, also regenerate the proto definition. See
// https://pub.dev/packages/proto_generator#getting-started.
@proto
class KnownDevice {
  static const _cacheKeyAllKnownDevices = 'known_devices';

  @ProtoField(2)
  final String advName;
  @ProtoField(3)
  final String platformName;
  @ProtoField(4)
  final String remoteId;
  // Intentionally not part of the proto, can not be encoded.
  BluetoothDevice? _bluetoothDevice;

  KnownDevice({
    required this.advName,
    required this.platformName,
    required this.remoteId,
    BluetoothDevice? bluetoothDevice,
  }) {
    _bluetoothDevice = bluetoothDevice;
  }

  static KnownDevice from(BluetoothDevice btDevice) {
    return KnownDevice(
      advName: btDevice.advName,
      platformName: btDevice.platformName,
      remoteId: btDevice.remoteId.str,
      bluetoothDevice: btDevice,
    );
  }

  BluetoothDevice get bluetoothDevice {
    if (_bluetoothDevice != null) {
      return _bluetoothDevice!;
    }
    return BluetoothDevice.fromId(remoteId);
  }

  String cacheKey() {
    return remoteId;
  }

  SensorHistory? getCachedSensorHistory(WidgetRef ref) {
    final preferencesAsync = ref.watch(fetchSharedPreferencesProvider);
    final key = cacheKey();
    return preferencesAsync.when(
      data: (prefs) {
        final encodedEntries = prefs.getString(key);
        if (encodedEntries == null) {
          log("No entries for device");
          return null;
        }
        return SensorHistory.from(encodedEntries);
      },
      error: (error, trace) {
        log('Key "$key" is not in shared preferences.');
        return null;
      },
      loading: () => null,
    );
  }

  Future<void> setCachedSensorHistory(
    WidgetRef ref,
    SensorHistory sensorHistory,
  ) async {
    final preferences = await ref.read(fetchSharedPreferencesProvider.future);

    final encodedEntries = sensorHistory.toBase64ProtoString();
    return preferences.setString(cacheKey(), encodedEntries);
  }

  static Iterable<KnownDevice> getAll(WidgetRef ref) {
    final preferencesAsync = ref.watch(fetchSharedPreferencesProvider);

    return preferencesAsync.when(
      data: (prefs) {
        final withNulls =
            prefs.getStringList(_cacheKeyAllKnownDevices)?.map((encodedDevice) {
              try {
                final deviceProto = GKnownDevice.fromBuffer(
                  base64Decode(encodedDevice),
                );
                return deviceProto.toKnownDevice();
              } on InvalidProtocolBufferException catch (e) {
                log("Could not decode known device.", error: e);
                return null;
              }
            }) ??
            [];
        return withNulls.where((d) => d != null).cast<KnownDevice>();
      },
      error: (error, trace) {
        log('Key "$_cacheKeyAllKnownDevices" is not in shared preferences.');
        return [];
      },
      loading: () => [],
    );
  }

  String encode() {
    return base64Encode(toProto().writeToBuffer());
  }

  static Future add(WidgetRef ref, BluetoothDevice btDevice) async {
    final preferences = await ref.read(fetchSharedPreferencesProvider.future);

    List<String> previousKnown = [];
    try {
      previousKnown = preferences.getStringList(_cacheKeyAllKnownDevices) ?? [];
    } on ArgumentError {
      log('No known devices in shared preferences.');
    }
    final encodedDevice = KnownDevice.from(btDevice).encode();
    if (!previousKnown.contains(encodedDevice)) {
      previousKnown.add(encodedDevice);
      await preferences.setStringList(_cacheKeyAllKnownDevices, previousKnown);
      ref.invalidate(fetchSharedPreferencesProvider);
    }
  }

  static Future remove(WidgetRef ref, KnownDevice device) async {
    final preferences = await ref.read(fetchSharedPreferencesProvider.future);

    List<String> previousKnown = [];
    try {
      previousKnown = preferences.getStringList(_cacheKeyAllKnownDevices) ?? [];
    } on ArgumentError {
      log('No known devices in shared preferences.');
    }
    final encodedDevice = device.encode();
    previousKnown.remove(encodedDevice);
    await preferences.setStringList(_cacheKeyAllKnownDevices, previousKnown);
    await preferences.remove(device.cacheKey()); // Removes cached sensor data.
    ref.invalidate(fetchSharedPreferencesProvider);
  }
}
