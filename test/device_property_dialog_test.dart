import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/widgets/device_property_dialog.dart';

void main() {
  testWidgets('DevicePropertyDialog defaults to local and returns selection', (
    tester,
  ) async {
    final device = BluetoothDevice.fromId('AA:BB:CC:DD:EE:FF');
    bool? selectedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  selectedResult = await showDialog<bool>(
                    context: context,
                    builder: (context) => DevicePropertyDialog(device: device),
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Connect to AA:BB:CC:DD:EE:FF'), findsOneWidget);
    expect(find.text('Local Time'), findsOneWidget);
    expect(find.text('UTC'), findsOneWidget);

    // Tap UTC
    await tester.tap(find.text('UTC'));
    await tester.pumpAndSettle();

    // Tap Connect
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(selectedResult, isTrue);
  });
}
