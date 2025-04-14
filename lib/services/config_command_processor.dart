import 'dart:developer';
import 'dart:typed_data';

import 'package:mi_thermo_reader/services/bluetooth_constants.dart';
import 'package:mi_thermo_reader/services/command_processor.dart';

class ConfigCommandProcessor extends CommandProcessor {
  @override
  void onData(List<int> values) {
    if (values.isEmpty) {
      return;
    }
    final data = ByteData.view(Uint8List.fromList(values).buffer);
    final blkid = data.getUint8(0);
    log('Got config: $data');

    if (blkid == BluetoothConstants.commandConfigBlk) {
      done.complete();
    }
  }
}
