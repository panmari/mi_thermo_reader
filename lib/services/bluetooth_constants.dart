import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothConstants {
  static final memoServiceGuid = Guid("1f10");
  static final memoCharacteristicGuid = Guid("1f1f");

  static const commandTimeBlk = 0x23;
  static const commandMemoBlk = 0x35;
}
