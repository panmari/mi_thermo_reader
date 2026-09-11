import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/services/bluetooth_advertisement_parsers/thermometer_advertisement.dart';
import 'package:mi_thermo_reader/utils/temperature.dart';
import 'package:region_settings/region_settings.dart';

void main() {
  group('ThermometerAdvertisement', () {
    test('temperatureIn converts correctly', () {
      final ad = ThermometerAdvertisement(
        temperature: 20.0,
        humidity: 50.0,
        batteryLevel: 90,
      );

      expect(ad.temperatureIn(TemperatureUnit.celsius), equals(20.0));
      expect(ad.temperatureIn(TemperatureUnit.fahrenheit), equals(68.0));
    });

    test('TemperatureConversion inUnit extension', () {
      expect(0.0.inUnit(TemperatureUnit.celsius), equals(0.0));
      expect(0.0.inUnit(TemperatureUnit.fahrenheit), equals(32.0));
      expect(100.0.inUnit(TemperatureUnit.fahrenheit), equals(212.0));
    });
  });
}
