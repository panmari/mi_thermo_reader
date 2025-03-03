import 'dart:io';

import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:path_provider/path_provider.dart';

class DiskOperations {
  static Future<bool> save(List<SensorEntry> entries) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('$directory/entries.txt');
    // TODO: Also include device id
    // TODO: Write content to file (in proto format).
    return true;
  }
}
