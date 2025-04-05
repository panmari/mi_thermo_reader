import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/services/bt_home_v2_parser.dart';

void main() {
  group('BtHomeV2Parser', () {
    test('Scraped example', () {
      final values = [64, 0, 167, 1, 92, 2, 29, 9, 3, 255, 14];

      final parsed = BTHomeV2Parser.parse(values);

      expect(
        parsed,
        equals({
          ObjectId.packedID: 167,
          ObjectId.battery: 92,
          ObjectId.temperature: 23.33,
          ObjectId.humidity: 38.39,
        }),
      );
    });

    test('All zeros', () {
      final values = [0x00, 0x00, 0x00, 0x00];

      expect(() => BTHomeV2Parser.parse(values), throwsA(isA<ArgumentError>()));
    });

    test('Encrypted payload', () {
      final values = [0x41];

      expect(
        () => BTHomeV2Parser.parse(values),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('No payload', () {
      final values = [0x40];

      final parsed = BTHomeV2Parser.parse(values);

      expect(parsed, equals({}));
    });

    test('Unknown ObjectId', () {
      final values = [0x40, 0x88];

      expect(
        () => BTHomeV2Parser.parse(values),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
