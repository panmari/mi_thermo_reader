// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:mi_thermo_reader/utils/sensor_entry.dart';

void main() {
  group('Parsing of response', () {
    test('Does something', () {
      // [53, 122, 0, 207, 161, 195, 103, 175, 8, 6, 17, 120, 11]
      final values = <int>[53, 122, 0, 207, 161, 195, 103, 175, 8, 6, 17, 120, 11];
      final uint8List = Uint8List.fromList(values);
      final data = ByteData.view(uint8List.buffer);
      final parsed = SensorEntry.parse(data);
      expect(parsed.index, equals(122));
      expect(parsed.timestamp, equals(DateTime(2025, 03, 02, 01, 09, 51)));
      expect(parsed.temperature, equals(22.23));
      expect(parsed.humidity, equals(43.58));
      expect(parsed.voltageBattery, equals(2936));
    });
  });
}
