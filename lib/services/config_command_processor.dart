import 'dart:developer';
import 'dart:typed_data';

import 'package:mi_thermo_reader/services/bluetooth_constants.dart';
import 'package:mi_thermo_reader/services/command_processor.dart';

class ConfigCommandProcessor extends CommandProcessor {
  ConfigCommandProcessor() : super(timeout: Duration(seconds: 5));

  @override
  void onData(List<int> values) {
    if (values.isEmpty) {
      return;
    }
    final data = ByteData.view(Uint8List.fromList(values).buffer);
    final blkid = data.getUint8(0);
    log('Got config: $values');

    if (blkid == BluetoothConstants.commandConfigBlk) {
      done.complete();
    }
  }
}
