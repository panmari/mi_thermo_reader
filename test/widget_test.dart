import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/services/bluetooth_constants.dart';

import 'package:mi_thermo_reader/widgets/scan_result_tile.dart';
import 'package:mi_thermo_reader/widgets/system_device_tile.dart';

void main() {
  group('ScanTile', () {
    testWidgets('Has ID and rssi', (tester) async {
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

      // Wrap ListTile with MaterialApp or another suitable parent widget.
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: scanTile)));

      final idFinder = find.text('06:E5:28:3B:FD:E0');
      final rssiFinder = find.text('31');

      expect(idFinder, findsOneWidget);
      expect(rssiFinder, findsOneWidget);
    });

    testWidgets('Parses advertisement data', (tester) async {
      final scanTile = ScanResultTile(
        result: ScanResult(
          device: BluetoothDevice.fromId('06:E5:28:3B:FD:E0'),
          advertisementData: AdvertisementData(
            advName: 'some_name',
            txPowerLevel: 11,
            appearance: 2,
            connectable: true,
            manufacturerData: {},
            serviceData: {
              BluetoothConstants.btHomeReversedGuid: [
                64,
                0,
                167,
                1,
                92,
                2,
                29,
                9,
                3,
                255,
                14,
              ],
            },
            serviceUuids: [],
          ),
          rssi: 31,
          timeStamp: DateTime.now(),
        ),
        onTap: () => 'nothing',
      );

      // Wrap ListTile with MaterialApp or another suitable parent widget.
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: scanTile)));

      final humidityFinder = find.textContaining('Humidity: 38.39');
      final temperatureFinder = find.textContaining('Temperature: 23.33');
      final batteryFinder = find.textContaining('Battery: 92');

      expect(humidityFinder, findsOneWidget);
      expect(temperatureFinder, findsOneWidget);
      expect(batteryFinder, findsOneWidget);
    });

    testWidgets('Parses incomplete advertisement data', (tester) async {
      final scanTile = ScanResultTile(
        result: ScanResult(
          device: BluetoothDevice.fromId('06:E5:28:3B:FD:E0'),
          advertisementData: AdvertisementData(
            advName: 'some_name',
            txPowerLevel: 11,
            appearance: 2,
            connectable: true,
            manufacturerData: {},
            serviceData: {
              BluetoothConstants.btHomeReversedGuid: [64, 0, 167, 1, 92],
            },
            serviceUuids: [],
          ),
          rssi: 31,
          timeStamp: DateTime.now(),
        ),
        onTap: () => 'nothing',
      );

      // Wrap ListTile with MaterialApp or another suitable parent widget.
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: scanTile)));

      final humidityFinder = find.textContaining('Humidity: NaN');
      final temperatureFinder = find.textContaining('Temperature: NaN');
      final batteryFinder = find.textContaining('Battery: 92');

      expect(humidityFinder, findsOneWidget);
      expect(temperatureFinder, findsOneWidget);
      expect(batteryFinder, findsOneWidget);
    });
  });

  group('DeviceTile', () {
    testWidgets('Has ID', (tester) async {
      final scanTile = SystemDeviceTile(
        device: BluetoothDevice.fromId('06:E5:28:3B:FD:E0'),
        onOpen: () => 'nothing',
      );

      // Wrap your ListTile with MaterialApp or another suitable parent widget.
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: scanTile)));

      final idFinder = find.text('06:E5:28:3B:FD:E0');

      expect(idFinder, findsOneWidget);
    });
  });
}
