import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';

import 'package:mi_thermo_reader/utils/sensor_history.dart';

void main() {
  group('Sensor history', () {
    test('Empty history returns default', () {
      final history = SensorHistory(sensorEntries: []);

      expect(history.averageInterval(), equals(Duration(minutes: 0)));
      expect(history.stdInterval(), equals(Duration(minutes: 0)));
    });

    test('One entry history returns default', () {
      final firstTime = DateTime(2025, 01, 02);
      final history = SensorHistory(
        sensorEntries: [
          SensorEntry(
            index: 0,
            timestamp: firstTime,
            temperature: 0,
            humidity: 0,
            voltageBattery: 0,
          ),
        ],
      );
      expect(history.averageInterval(), equals(Duration(minutes: 0)));
      expect(history.stdInterval(), equals(Duration(minutes: 0)));
    });

    test('Computes stats for regular 10m interval', () {
      final firstTime = DateTime(2025, 01, 02);
      final history = SensorHistory(
        sensorEntries: [
          SensorEntry(
            index: 0,
            timestamp: firstTime,
            temperature: 0,
            humidity: 0,
            voltageBattery: 0,
          ),
          SensorEntry(
            index: 1,
            timestamp: firstTime.add(Duration(minutes: 10)),
            temperature: 0,
            humidity: 0,
            voltageBattery: 0,
          ),
          SensorEntry(
            index: 2,
            timestamp: firstTime.add(Duration(minutes: 20)),
            temperature: 0,
            humidity: 0,
            voltageBattery: 0,
          ),
        ],
      );

      expect(history.averageInterval(), equals(Duration(minutes: 10)));
      expect(history.stdInterval(), equals(Duration(minutes: 0)));
    });

    test('Computes stats for irregular interval', () {
      final firstTime = DateTime(2025, 01, 02);
      final history = SensorHistory(
        sensorEntries: [
          SensorEntry(
            index: 0,
            timestamp: firstTime,
            temperature: 0,
            humidity: 0,
            voltageBattery: 0,
          ),
          SensorEntry(
            index: 1,
            timestamp: firstTime.add(Duration(minutes: 5)),
            temperature: 0,
            humidity: 0,
            voltageBattery: 0,
          ),
          SensorEntry(
            index: 2,
            timestamp: firstTime.add(Duration(minutes: 19)),
            temperature: 0,
            humidity: 0,
            voltageBattery: 0,
          ),
        ],
      );

      expect(history.averageInterval(), equals(Duration(minutes: 9, seconds: 30)));
      expect(history.stdInterval(), equals(Duration(minutes: 4, seconds: 30)));
    });
  });
}
