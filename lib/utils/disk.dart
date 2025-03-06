import 'dart:io';

import 'package:mi_thermo_reader/src/proto/model.pb.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/protobuf.dart';

class DiskOperations {
  static Future<String> _filepath(String deviceIdentifier) {
    return getApplicationDocumentsDirectory().then(
      (d) => '$d/$deviceIdentifier/sensor_entries.pb',
    );
  }

  // Writes the given sensor entries to a file.
  static Future<File> save(
    String deviceIdentifier,
    List<SensorEntry> entries,
  ) async {
    final filePath = await _filepath(deviceIdentifier);
    final file = File(filePath);
    return file.writeAsBytes(
      SensorHistory(sensorEntries: entries).toProto().writeToBuffer(),
    );
  }

  static Future<List<SensorEntry>> load(String deviceIdentifier) async {
    final filePath = await _filepath(deviceIdentifier);
    final bytes = File(filePath).readAsBytesSync();

    return GSensorHistory.fromBuffer(bytes).toSensorHistory().sensorEntries;
  }
}
