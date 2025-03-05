import 'dart:io';

import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/protobuf.dart';

class DiskOperations {

  // Writes the given sensor entries to a file.
  static Future<File> save(String deviceIdentifier, List<SensorEntry> entries) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('$directory/$deviceIdentifier/sensor_entries.pb');
    final buffer = CodedBufferWriter();
    for (SensorEntry e in entries) {
      e.toProto().writeToCodedBufferWriter(buffer);
    }
    return file.writeAsBytes(buffer.toBuffer());
  }
}
