import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothConstants {
  static final sensorAdvertisementServiceGuid = Guid("181a");
  static final memoServiceGuid = Guid("1f10");
  static final memoCharacteristicGuid = Guid("1f1f");

  static final memoServiceTHB2Guid = Guid("fcd2");
  static final memoCharacteristicTHB2Guid = Guid("fff4");

  static const commandTimeBlk = 0x23;
  static const commandMemoBlk = 0x35;
  static const commandConfigBlk = 0x55;

  // See https://bthome.io/format/
  static final btHomeReversedGuid = Guid("fcd2");
  // See https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#custom-format-all-data-little-endian
  static final pvvxAdvertisingFormatGuid = Guid("181a");
}
