import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';

import 'app_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SharedPreferencesWithCache>()])
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final mockPreferences = MockSharedPreferencesWithCache();

  setUp(() {
    when(mockPreferences.getStringList('known_devices')).thenReturn([
      KnownDevice(
        advName: 'Living room thermometer',
        platformName: 'Some platform name',
        remoteId: '00:00:01:44',
      ).encode(),
      KnownDevice(
        advName: 'Bed room thermometer',
        platformName: 'Some other platform name',
        remoteId: '00:00:01:33',
      ).encode(),
    ]);
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

      await tester.tap(find.text('Living room thermometer'));
      await tester.pumpAndSettle();

      // Device space should show detailed name.
      expect(find.text('00:00:01:44'), findsOneWidget);
    });

    testWidgets('Device page shows stuff', (tester) async {
      // TODO
    });
  });
}
