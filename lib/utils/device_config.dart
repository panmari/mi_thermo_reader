import 'dart:typed_data';

class DeviceConfig {
  late int version;
  late int flg;
  late int flg2;
  late bool comfort;
  late bool screenOff;
  late TemperatureUnit temperatureUnit;
  late int tempOffset;
  late int humiOffset;
  late int advertisingIntervalSteps; // In steps, actual interval is * 62.5 ms.
  late int measureIntervalSteps;
  late int rfTxPower;
  late int connectLatencySteps; // In steps, actual latency is (x + 1) * 20 ms
  late int lcdTint;
  // int? hver;
  late int avMeasMem;

  static DeviceConfig parse(ByteData byteData) {
    final cfg = DeviceConfig();
    cfg.version = byteData.getUint8(1);
    cfg.flg = byteData.getUint8(2);
    cfg.flg2 = byteData.getUint8(3);
    cfg.comfort = cfg.flg & 4 != 0;
    cfg.screenOff = cfg.flg2 & 0x80 != 0;
    cfg.temperatureUnit =
        cfg.flg & 16 == 0
            ? TemperatureUnit.celsius
            : TemperatureUnit.fahrenheit;
    cfg.tempOffset = byteData.getInt8(4);
    cfg.humiOffset = byteData.getInt8(5);
    cfg.advertisingIntervalSteps = byteData.getUint8(6);
    cfg.measureIntervalSteps = byteData.getUint8(7);
    cfg.rfTxPower = byteData.getUint8(8);
    // if ((cfg.rfTxPower & 0x80) == 0) MAX_RF_TX_Power = true;
    cfg.connectLatencySteps = byteData.getUint8(9);
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

  Duration get advertisingInterval {
    // Specify as microseconds to avoid rounding errors.
    return Duration(
      microseconds: (advertisingIntervalSteps * 62.5 * 1000).round(),
    );
  }

  Duration get connectLatency {
    return Duration(
      microseconds: ((connectLatencySteps + 1) * 20 * 1000).round(),
    );
  }
}

enum TemperatureUnit { celsius, fahrenheit }
