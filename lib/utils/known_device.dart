import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:proto_annotations/proto_annotations.dart';
import 'package:protobuf/protobuf.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  static Future<SharedPreferencesWithCache> _getSharedPreferences(
    BuildContext context,
  ) {
    return Provider.of<Future<SharedPreferencesWithCache>>(
      context,
      listen: false,
    );
  }

  static Future<Iterable<KnownDevice>> getAll(BuildContext context) async {
    final preferences = await _getSharedPreferences(context);

    try {
      final encodedDevices = preferences.getStringList(cacheKey);
      if (encodedDevices == null) {
        log('Shared preferences returned null.');
        return [];
      }
      final withNulls = encodedDevices.map((encodedDevice) {
        try {
          final deviceProto = GKnownDevice.fromBuffer(
            base64Decode(encodedDevice),
          );
          return deviceProto.toKnownDevice();
        } on InvalidProtocolBufferException catch (e) {
          log("Could not decode known device.", error: e);
          return null;
        }
      });
      return withNulls.where((d) => d != null).cast<KnownDevice>();
    } on ArgumentError {
      log('Key "$cacheKey" is not in shared preferences.');
    }
    return [];
  }

  static Future<void> add(BuildContext context, BluetoothDevice device) async {
    final preferences = await _getSharedPreferences(context);

    List<String> previousKnown = [];
    try {
      previousKnown = preferences.getStringList(cacheKey) ?? [];
    } on ArgumentError {
      log('No known devices in shared preferences.');
    }
    final encodedDevice = base64Encode(
      KnownDevice(
        advName: device.advName,
        platformName: device.platformName,
        remoteId: device.remoteId.str,
      ).toProto().writeToBuffer(),
    );
    if (!previousKnown.contains(encodedDevice)) {
      previousKnown.add(encodedDevice);
      return preferences.setStringList(cacheKey, previousKnown);
    }
  }
}
