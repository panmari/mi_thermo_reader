import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mi_thermo_reader/widgets/scan_result_tile.dart';

void main() {
  group('ScanTile', () {
    testWidgets('Has ID', (tester) async {
      final scanTile = ScanResultTile(
        result: ScanResult(
          device: BluetoothDevice.fromId('06:E5:28:3B:FD:E0'),
          advertisementData: AdvertisementData(
            advName: 'some_name',
            txPowerLevel: 11,
            appearance: 2,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: [],
          ),
          rssi: 31,
          timeStamp: DateTime.now(),
        ),
        onTap: () => 'nothing',
      );

      // Wrap your ListTile with MaterialApp or another suitable parent widget.
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: scanTile)));

      final idFinder = find.text('06:E5:28:3B:FD:E0');

      expect(idFinder, findsOneWidget);
    });
  });
}
