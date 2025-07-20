import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/home_page.dart';
import 'package:mi_thermo_reader/main.dart';

import 'device_screen_test.mocks.dart';

base class _FakeFlutterBluePlus extends FlutterBluePlusPlatform {
  @override
  Stream<BmBluetoothAdapterState> get onAdapterStateChanged {
    return Stream.value(
      BmBluetoothAdapterState(adapterState: BmAdapterStateEnum.on),
    );
  }
}

void main() {
  final mockPreferences = MockSharedPreferencesWithCache();

  setUp(() {
    FlutterBluePlusPlatform.instance = _FakeFlutterBluePlus();
  });

  testWidgets('HomePage if bluetooth is on has "Add device" button', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fetchSharedPreferencesProvider.overrideWith((_) => mockPreferences),
        ],
        child: const MaterialApp(home: MiThermoReaderHomePage()),
      ),
    );
    // Verify that the initial state is displayed.
    expect(find.text('Bluetooth adapter state is unknown'), findsOneWidget);

    // The adapter state is delivered via a stream. We need to pump the
    // widget again to process the state update.
    await tester.pump();

    // Verify that a "add" card is displayed.
    expect(find.widgetWithText(OutlinedButton, 'Add device'), findsOneWidget);
  });
}
