import 'dart:typed_data';

class DeviceConfig {
  late int ver;
  late int flg;
  late int flg2;
  late int tempOffset;
  late int humiOffset;
  late int advertisingInterval;
  late int measureInterval;
  late int rfTxPower;
  late int connectLatency;
  late int lcdTint;
  // int? hver;
  late int avMeasMem;

  static DeviceConfig parse(ByteData byteData) {
    final cfg = DeviceConfig();
    cfg.ver = byteData.getUint8(1);
    cfg.flg = byteData.getUint8(2);
    cfg.flg2 = byteData.getUint8(3);
    cfg.tempOffset = byteData.getInt8(4);
    cfg.humiOffset = byteData.getInt8(5);
    cfg.advertisingInterval = byteData.getUint8(6);
    cfg.measureInterval = byteData.getUint8(7);
    cfg.rfTxPower = byteData.getUint8(8);
    // if ((cfg.rfTxPower & 0x80) == 0) MAX_RF_TX_Power = true;
    cfg.connectLatency = byteData.getUint8(9);
    cfg.lcdTint = byteData.lengthInBytes >= 10 ? byteData.getUint8(10) : 55;
    // cfg.hver = byteData.lengthInBytes >= 11 ? byteData.getUint8(11);
    //   if (cfg.ver < 0x36) cfg.hver = cfg.hver! & 0x87;
    // } else {
    //   cfg.hver ??= 0x80;
    // }
    // ;
    cfg.avMeasMem = byteData.lengthInBytes >= 12 ? byteData.getUint8(12) : 0;
    return cfg;
  }
}
