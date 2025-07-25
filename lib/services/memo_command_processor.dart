import 'dart:typed_data';

import 'package:mi_thermo_reader/services/bluetooth_constants.dart';
import 'package:mi_thermo_reader/services/command_processor.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';

class MemoCommandProcessor extends CommandProcessor<List<SensorEntry>> {
  final Function(String) statusUpdate;
  final _sensorEntries = <SensorEntry>[];

  MemoCommandProcessor({required this.statusUpdate})
    : super(timeout: const Duration(seconds: 60));

  @override
  void onData(List<int> values) {
    if (values.isEmpty) {
      return;
    }
    final data = ByteData.view(Uint8List.fromList(values).buffer);
    final blkid = data.getInt8(0);
    if (blkid != BluetoothConstants.commandMemoBlk) {
      statusUpdate("data with unexpected blkid $blkid: $values");
      return;
    }
    if (data.lengthInBytes >= 13) {
      // Got an entry from memory. Convert it to a SensorEntry.
      _sensorEntries.add(SensorEntry.parse(data));
      return;
    }
    if (data.lengthInBytes >= 3) {
      statusUpdate('Done with reading. Got ${_sensorEntries.length} samples');
      done.complete(_sensorEntries);
      return;
    }
    if (data.lengthInBytes == 2) {
      // TODO(panmari): This message seems pointless. Seems to be mostly 0 if received.
      final numSamples = data.getUint16(1, Endian.little);
      statusUpdate('Number of samples in memory: $numSamples');
      return;
    }
    statusUpdate("data with unexpected size data.lengthInBytes: $data");
  }
}
