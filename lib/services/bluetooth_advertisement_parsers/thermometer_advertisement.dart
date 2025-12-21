import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/services/bluetooth_advertisement_parsers/bt_home_v2_parser.dart';
import 'package:mi_thermo_reader/services/bluetooth_advertisement_parsers/pvvx_parser.dart';
import 'package:mi_thermo_reader/services/bluetooth_constants.dart';

class NoAdvertisementDataFound implements Exception {
  @override
  String toString() => 'No advertisement data found.';
}

class AdvertisementDataFormatNotSupported implements Exception {
  @override
  String toString() => 'Advertisement data format not supported.';
}

class ThermometerAdvertisement {
  final double temperature;
  final double humidity;
  final int batteryLevel;

  static ThermometerAdvertisement create(AdvertisementData advertisementData) {
    if (advertisementData.serviceData.isEmpty) {
      throw NoAdvertisementDataFound();
    }
    final btHomeValues =
        advertisementData.serviceData[BluetoothConstants.btHomeReversedGuid];
    if (btHomeValues != null) {
      final parsed = BTHomeV2Parser.parse(btHomeValues);

      return ThermometerAdvertisement(
        temperature: parsed[ObjectId.temperature] as double? ?? double.nan,
        humidity: parsed[ObjectId.humidity] as double? ?? double.nan,
        batteryLevel: parsed[ObjectId.battery] as int? ?? -1,
      );
    }
    final pvvxValues =
        advertisementData.serviceData[BluetoothConstants
            .pvvxAdvertisingFormatGuid];
    if (pvvxValues != null) {
      final parsed = PvvxParser.parse(pvvxValues);

      return ThermometerAdvertisement(
        temperature: parsed.temperature,
        humidity: parsed.humidity,
        batteryLevel: parsed.batteryLevel,
      );
    }

    throw AdvertisementDataFormatNotSupported();
  }

  ThermometerAdvertisement({
    required this.temperature,
    required this.humidity,
    required this.batteryLevel,
  });
}
