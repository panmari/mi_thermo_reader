import 'dart:developer';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_thermo_reader/main.dart';
import 'package:proto_annotations/proto_annotations.dart';
import 'package:protobuf/protobuf.dart';
import 'package:mi_thermo_reader/src/proto/model.pb.dart';

part 'known_device.g.dart';

// After changing this file, also regenerate the proto definition. See
// https://pub.dev/packages/proto_generator#getting-started.
@proto
class KnownDevice {
  static const cacheKey = 'known_devices';

  @ProtoField(2)
  final String advName;
  @ProtoField(3)
  final String platformName;
  @ProtoField(4)
  final String remoteId;

  KnownDevice({
    required this.advName,
    required this.platformName,
    required this.remoteId,
  });

  static Iterable<KnownDevice> getAll(WidgetRef ref) {
    final preferencesAsync = ref.watch(fetchSharedPreferencesProvider);

    return preferencesAsync.when(
      data: (prefs) {
        final withNulls =
            prefs.getStringList(cacheKey)?.map((encodedDevice) {
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
        log('Key "$cacheKey" is not in shared preferences.');
        return [];
      },
      loading: () => [],
    );
  }

  static String _encode(KnownDevice device) {
    return base64Encode(device.toProto().writeToBuffer());
  }

  static Future add(WidgetRef ref, BluetoothDevice device) async {
    final preferences = await ref.read(fetchSharedPreferencesProvider.future);

    List<String> previousKnown = [];
    try {
      previousKnown = preferences.getStringList(cacheKey) ?? [];
    } on ArgumentError {
      log('No known devices in shared preferences.');
    }
    final encodedDevice = _encode(
      KnownDevice(
        advName: device.advName,
        platformName: device.platformName,
        remoteId: device.remoteId.str,
      ),
    );
    if (!previousKnown.contains(encodedDevice)) {
      previousKnown.add(encodedDevice);
      await preferences.setStringList(cacheKey, previousKnown);
      ref.invalidate(fetchSharedPreferencesProvider);
    }
  }

  static Future remove(WidgetRef ref, KnownDevice device) async {
    final preferences = await ref.read(fetchSharedPreferencesProvider.future);

    List<String> previousKnown = [];
    try {
      previousKnown = preferences.getStringList(cacheKey) ?? [];
    } on ArgumentError {
      log('No known devices in shared preferences.');
    }
    final encodedDevice = _encode(device);
    previousKnown.remove(encodedDevice);
    await preferences.setStringList(cacheKey, previousKnown);
    ref.invalidate(fetchSharedPreferencesProvider);
  }
}
