import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/src/proto/model.pb.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:path_provider/path_provider.dart';

class DiskOperations {
  static Future<String> _filepath(BluetoothDevice device) {
    return getApplicationDocumentsDirectory().then(
      (d) => '$d/${device.remoteId.str}/sensor_entries.pb',
    );
  }

  // Writes the given sensor entries to a file.
  static Future<File> save(
    BluetoothDevice device,
    List<SensorEntry> entries,
  ) async {
    final filePath = await _filepath(device);
    final file = File(filePath);
    return file.writeAsBytes(
      SensorHistory(sensorEntries: entries).toProto().writeToBuffer(),
    );
  }

  static Future<List<SensorEntry>> load(BluetoothDevice device) async {
    final filePath = await _filepath(device);
    final bytes = File(filePath).readAsBytesSync();

    return GSensorHistory.fromBuffer(bytes).toSensorHistory().sensorEntries;
  }
}
