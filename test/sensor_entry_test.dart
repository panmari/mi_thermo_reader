import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:region_settings/region_settings.dart';

void main() {
  group('Sensor entry', () {
    test('Correctly parses attributes', () {
      // [53, 122, 0, 207, 161, 195, 103, 175, 8, 6, 17, 120, 11]
      final values = <int>[
        53,
        122,
        0,
        207,
        161,
        195,
        103,
        175,
        8,
        6,
        17,
        120,
        11,
      ];
      final uint8List = Uint8List.fromList(values);
      final data = ByteData.view(uint8List.buffer);
      final parsed = SensorEntry.parse(data);

      expect(parsed.index, equals(122));
      expect(
        parsed.timestamp,
        equals(DateTime.fromMillisecondsSinceEpoch(1740874191000)),
      );
      expect(parsed.temperature, equals(22.23));
      expect(parsed.temperatureIn(TemperatureUnit.fahrenheit), equals(72.014));
      expect(parsed.temperatureIn(TemperatureUnit.celsius), equals(22.23));
      expect(parsed.humidity, equals(43.58));
      expect(parsed.voltageBattery, equals(2936));
    });
  });
}
