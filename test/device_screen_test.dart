import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/device_screen.dart';
import 'package:mi_thermo_reader/main.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
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
  });
}
