import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/device_screen.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mi_thermo_reader/widgets/error_message.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

import 'device_screen_test.mocks.dart';
import 'fake_shared_preferences_async.dart';

@GenerateMocks([fbp.BluetoothDevice])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockBtDevice = MockBluetoothDevice();
  final testKnownDevice = KnownDevice(
    advName: "test adv name",
    platformName: "test platform name",
    remoteId: "00:11:22",
    bluetoothDevice: mockBtDevice,
  );

  when(mockBtDevice.remoteId).thenReturn(DeviceIdentifier("00:11:22"));
  when(mockBtDevice.isConnected).thenReturn(true);
  when(mockBtDevice.disconnect());

  group('DeviceScreen Tests', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance = FakeSharedPreferencesAsync();
      FlutterBluePlusPlatform.instance = FakeFlutterBluePlus();
    });

    tearDown(() {
      SharedPreferencesAsyncPlatform.instance = null;
    });

    testWidgets('displays device info and update button initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: DeviceScreen(device: testKnownDevice)),
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
      expect(find.byTooltip(RegExp("Fix Time")), findsOneWidget);
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

base class FakeFlutterBluePlus extends FlutterBluePlusPlatform {}
