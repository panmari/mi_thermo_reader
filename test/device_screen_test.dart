import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/device_screen.dart';
import 'package:mi_thermo_reader/main.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
import 'package:mi_thermo_reader/widgets/popup_menu.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:mi_thermo_reader/utils/sensor_history.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mi_thermo_reader/widgets/error_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

import 'device_screen_test.mocks.dart';

base class _FakeFlutterBluePlus extends FlutterBluePlusPlatform {}

@GenerateNiceMocks([
  MockSpec<fbp.BluetoothDevice>(),
  MockSpec<SharedPreferencesWithCache>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockPreferences = MockSharedPreferencesWithCache();
  final mockBtDevice = MockBluetoothDevice();
  final testKnownDevice = KnownDevice(
    advName: "test adv name",
    platformName: "test platform name",
    remoteId: "00:11:22",
    bluetoothDevice: mockBtDevice,
  );

  group('DeviceScreen Tests', () {
    setUp(() {
      FlutterBluePlusPlatform.instance = _FakeFlutterBluePlus();
      when(mockBtDevice.remoteId).thenReturn(DeviceIdentifier("00:11:22"));
      when(mockBtDevice.isConnected).thenReturn(true);
      when(mockBtDevice.disconnect()).thenAnswer((_) async {});
      when(mockPreferences.getString('00:11:22')).thenReturn("");
    });

    tearDown(() {
      SharedPreferencesAsyncPlatform.instance = null;
    });

    testWidgets('displays device info and update button initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchSharedPreferencesProvider.overrideWith((_) => mockPreferences),
          ],
          child: MaterialApp(home: DeviceScreen(device: testKnownDevice)),
        ),
      );

      expect(find.text('test platform name, (00:11:22)'), findsOneWidget);
      expect(
        find.byTooltip('Updates data by connecting to the device.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton))
            .onPressed,
        isNotNull,
      );
      expect(
        find.text("No entries available, click [Update] to fetch data"),
        findsOneWidget,
      );
      expect(find.byType(ErrorMessage), findsNothing);
      expect(
        find.byType(ChoiceChip),
        findsNWidgets(DayFilterOption.values.length),
      );
      expect(find.text('All'), findsOneWidget);
      expect(find.text('last day'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);
      expect(find.text('30 days'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('shows correct popup menu content no sensor history', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fetchSharedPreferencesProvider.overrideWith((_) => mockPreferences),
          ],
          child: MaterialApp(home: DeviceScreen(device: testKnownDevice)),
        ),
      );

      await tester.tap(find.byType(PopupMenu));
      await tester.pumpAndSettle();

      expect(find.text("Adjust time"), findsOneWidget);
      expect(find.text("Rate this app"), findsOneWidget);
      expect(find.text("About"), findsOneWidget);
      // No data to export or delete, so this is not displayed.
      expect(find.text("Export to CSV"), findsNothing);
      expect(find.text("Delete date range"), findsNothing);
    });

    testWidgets(
      'shows correct popup menu content with sensor history and allows deleting',
      (WidgetTester tester) async {
        final now = DateTime.now();
        final sensorHistory = SensorHistory(
          sensorEntries: [
            SensorEntry(
              index: 0,
              timestamp: now,
              temperature: 20.0,
              humidity: 50.0,
              voltageBattery: 3000,
            ),
          ],
        );
        when(
          mockPreferences.getString('00:11:22'),
        ).thenReturn(sensorHistory.toBase64ProtoString());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              fetchSharedPreferencesProvider.overrideWith(
                (_) => mockPreferences,
              ),
            ],
            child: MaterialApp(home: DeviceScreen(device: testKnownDevice)),
          ),
        );

        await tester.tap(find.byType(PopupMenu));
        await tester.pumpAndSettle();

        expect(find.text("Adjust time"), findsOneWidget);
        expect(find.text("Rate this app"), findsOneWidget);
        expect(find.text("About"), findsOneWidget);
        expect(find.text("Export to CSV"), findsOneWidget);
        expect(find.text("Delete date range"), findsOneWidget);

        // Open the delete dialog.
        await tester.tap(find.text("Delete date range"));
        await tester.pumpAndSettle();

        expect(find.text('Select date range to delete'), findsOneWidget);

        // Select date range.
        await tester.tap(find.text(now.day.toString()));
        await tester.pumpAndSettle();
        await tester.tap(find.text(now.day.toString()));
        await tester.pumpAndSettle();

        // Click delete.
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        // Verify data is deleted.
        verify(
          mockPreferences.setString(
            '00:11:22',
            SensorHistory(sensorEntries: []).toBase64ProtoString(),
          ),
        );
      },
    );
  });
}
