import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:mi_thermo_reader/utils/sensor_history.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';

import 'app_test.mocks.dart';

List<SensorEntry> _createFakeSensorData(int nElements) {
  double lastTemp = 21.0;
  double lastHum = 51.0;
  return List.generate(nElements, (i) {
    lastTemp += math.Random().nextDouble() * 0.1 - 0.05;
    lastHum += math.Random().nextDouble() - 0.5;
    return SensorEntry(
      index: i,
      timestamp: DateTime.now().subtract(
        Duration(minutes: (nElements - i) * 10),
      ),
      temperature: lastTemp,
      humidity: lastHum,
      voltageBattery: 0,
    );
  });
}

@GenerateNiceMocks([MockSpec<SharedPreferencesWithCache>()])
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockPreferences = MockSharedPreferencesWithCache();

  setUp(() {
    when(mockPreferences.getStringList('known_devices')).thenReturn([
      KnownDevice(
        advName: 'Living room thermometer',
        platformName: 'Living room',
        remoteId: '00:00:01:44',
      ).encode(),
      KnownDevice(
        advName: 'Bed room thermometer',
        platformName: 'Bed room',
        remoteId: '00:00:01:33',
      ).encode(),
    ]);
    when(mockPreferences.getString('00:00:01:44')).thenReturn(
      SensorHistory(
        sensorEntries: _createFakeSensorData(200),
      ).toBase64ProtoString(),
    );
  });

  tearDown(() {
    reset(mockPreferences);
  });

  group('end-to-end test', () {
    testWidgets('Show known devices on home and clickable', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchSharedPreferencesProvider.overrideWith((_) => mockPreferences),
          ],
          child: const MyApp(),
        ),
      );
      // This is required prior to taking the screenshot (Android only).
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();

      await binding.takeScreenshot("home_screen_with_known_devices");

      expect(find.text('Living room thermometer'), findsOneWidget);
      expect(find.text('Bed room thermometer'), findsOneWidget);
    });

    testWidgets('Device page shows stuff', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchSharedPreferencesProvider.overrideWith((_) => mockPreferences),
          ],
          child: const MyApp(),
        ),
      );
      // This is required prior to taking the screenshot (Android only).
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();

      // Does not correctly open device screen.
      await tester.tap(find.text('Open').first);
      await tester.pumpAndSettle();

      await binding.takeScreenshot("device_screen_no_data");

      // Device space should show detailed name.
      expect(find.text('Living room, (00:00:01:44)'), findsOneWidget);
      expect(
        find.text('No entries available, click [Update] to fetch data'),
        findsOneWidget,
      );

      await tester.tap(
        find.byTooltip("Updates data by connecting to the device.").first,
      );
      await tester.pumpAndSettle();
      await binding.takeScreenshot("device_screen_no_data");
    });
  });
}
