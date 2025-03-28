import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/services/bluetooth_commands.dart';
import 'package:mi_thermo_reader/services/bluetooth_constants.dart';
import 'package:mi_thermo_reader/services/memo_service_processor.dart';
import 'package:mi_thermo_reader/services/time_command_processor.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';

class BluetoothManager {
  final BluetoothDevice device;
  BluetoothCharacteristic? _characteristic;

  BluetoothManager({required this.device});

  Future<void> init(Function(String) statusUpdate) async {
    if (_characteristic != null) {
      statusUpdate("Already initialized.");
      return;
    }
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
    _characteristic = memoService.characteristics.firstWhere(
      (c) => c.characteristicUuid == BluetoothConstants.memoCharacteristicGuid,
    );
    statusUpdate('Found memo characteristic.');

    await _characteristic!.setNotifyValue(true);
    statusUpdate('Subscribed to notifications');
  }

  Future<List<SensorEntry>> getMemoryData(Function(String) statusUpdate) async {
    if (_characteristic == null) {
      statusUpdate('Not initialized.');
      return [];
    }
    final processor = MemoServiceProcessor(statusUpdate: statusUpdate);
    final valueSubscription = _characteristic!.onValueReceived.listen(
      processor.onData,
      onError: processor.onError,
    );
    device.cancelWhenDisconnected(valueSubscription);

    await _characteristic!.write(
      BluetoothCommands.getMemoCommand(5000),
      withoutResponse: true,
    );
    statusUpdate("Start get memo: Success");

    final result = await processor.waitForResults();
    valueSubscription.cancel();

    return result;
  }

  Future<Duration> getDeviceTimeAndDrift() async {
    if (_characteristic == null) {
      throw "Not initialized";
    }
    final processor = TimeCommandProcessor();
    final valueSubscription = _characteristic!.onValueReceived.listen(
      processor.onData,
      onError: processor.onError,
    );

    await _characteristic!.write(
      BluetoothCommands.getDeviceTime(),
      withoutResponse: true,
    );

    final drift = processor.waitForResults();
    valueSubscription.cancel();

    return drift;
  }

  // Because of time drifts on the device, calling this occasionally is necessary.
  Future<void> setDeviceTimeToNow() {
    if (_characteristic == null) {
      throw "Not initialized";
    }
    final now = DateTime.now();
    return _characteristic!.write(
      BluetoothCommands.setDeviceTime(now),
      withoutResponse: true,
    );
  }

  void dispose() {
    // TODO(panmari): Should this disconnect? Or keep the connection open if the user returns?
    device.disconnect();
  }
}
