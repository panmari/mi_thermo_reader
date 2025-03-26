import 'dart:typed_data';

import 'package:mi_thermo_reader/services/bluetooth_constants.dart';

class BluetoothCommands {
  /// numMemos is the number of entries to retrieve from memory, starting with the most recent entry.
  static List<int> getMemoCommand(int numMemos) {
    // Send command to read memory measures.
    // See https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#primary-service-uuid-0x1f10-characteristic-uuid-0x1f1f
    // The two parameters are:
    final lastNumMemo = numMemos;
    final skipNumMemo = 0; // How many records to skip from the start.
    final request = Uint8List(5).buffer.asByteData();
    request.setUint8(0, BluetoothConstants.getMemoCommandBlk);
    request.setUint16(1, lastNumMemo, Endian.little);
    request.setUint16(3, skipNumMemo, Endian.little);
    return request.buffer.asUint8List();
  }

  static List<int> setDeviceTime(DateTime time) {
    // The original code adjusted to timezone. That doesn't seem necessary,
    // as Epoch is independent of timezone. Timezone should be applied when converting back.
    final secondsSinceEpoch = time.millisecondsSinceEpoch ~/ 1000;

    final request = Uint8List(5).buffer.asByteData();
    request.setUint8(0, BluetoothConstants.setTimeBlk);
    request.setUint32(1, secondsSinceEpoch, Endian.little);
    return request.buffer.asUint8List();
  }
}
