import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/services/bluetooth_commands.dart';
import 'package:mi_thermo_reader/services/bluetooth_constants.dart';
import 'package:mi_thermo_reader/services/memo_service_processor.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';

class BluetoothManager {
  final BluetoothDevice device;
  StreamSubscription<List<int>>? _valueSubscription;

  BluetoothManager({required this.device});

  Future<List<SensorEntry>> getMemoryData(Function(String) statusUpdate) async {
    await device.connect();
    statusUpdate("Connect: Success");

    final services = await device.discoverServices(
      subscribeToServicesChanged: false,
    );
    statusUpdate("Discover Services: Success");

    // https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#bluetooth-connection-mode
    final memoService = services.firstWhere(
      (service) =>
          service.isPrimary &&
          service.serviceUuid == BluetoothConstants.memoServiceGuid,
    );
    final memoCharacteristic = memoService.characteristics.firstWhere(
      (c) => c.characteristicUuid == BluetoothConstants.memoCharacteristicGuid,
    );
    statusUpdate('Found memo characteristic.');

    final processor = MemoServiceProcessor(statusUpdate: statusUpdate);
    _valueSubscription = memoCharacteristic.onValueReceived.listen(
      processor.onData,
      onError: processor.onError,
    );
    device.cancelWhenDisconnected(_valueSubscription!);

    await memoCharacteristic.setNotifyValue(true);
    statusUpdate('Subscribed to memo notifications');

    await memoCharacteristic.write(
      BluetoothCommands.getMemoCommand(5000),
      withoutResponse: true,
    );
    statusUpdate("Start get memo: Success");

    return processor.waitForResults();
  }
}
