import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KnownDevices {
  static const cacheKey = 'known_devies';

  static Future<SharedPreferencesWithCache> _getSharedPreferences(
    BuildContext context,
  ) {
    return Provider.of<Future<SharedPreferencesWithCache>>(
      context,
      listen: false,
    );
  }

  static Future<Iterable<BluetoothDevice>> getKnownDevices(
    BuildContext context,
  ) async {
    final preferences = await _getSharedPreferences(context);

    try {
      return preferences
          .getStringList(cacheKey)!
          .map((id) => BluetoothDevice.fromId(id));
    } on ArgumentError {
      log('No known devices in shared preferences.');
    }
    return [];
  }

  static Future<void> addKnownDevice(
    BuildContext context,
    BluetoothDevice device,
  ) async {
    final preferences = await _getSharedPreferences(context);

    List<String> previousKnown = [];
    try {
      previousKnown = preferences.getStringList(cacheKey) ?? [];
    } on ArgumentError {
      log('No known devices in shared preferences.');
    }
    final identifier = device.remoteId.str;
    if (!previousKnown.contains(identifier)) {
      previousKnown.add(identifier);
      return preferences.setStringList(cacheKey, previousKnown);
    }
  }
}
