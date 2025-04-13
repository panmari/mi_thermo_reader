import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/services/bluetooth_commands.dart';
import 'package:mi_thermo_reader/services/bluetooth_constants.dart';
import 'package:mi_thermo_reader/services/command_processor.dart';
import 'package:mi_thermo_reader/services/config_command_processor.dart';
import 'package:mi_thermo_reader/services/memo_command_processor.dart';
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
    final memoService = services.firstWhereOrNull(
      (service) =>
          service.isPrimary &&
          service.serviceUuid == BluetoothConstants.memoServiceGuid,
    );
    if (memoService == null) {
      throw 'Failed to find service ${BluetoothConstants.memoServiceGuid}';
    }
    _characteristic = memoService.characteristics.firstWhereOrNull(
      (c) => c.characteristicUuid == BluetoothConstants.memoCharacteristicGuid,
    );
    if (_characteristic == null) {
      throw 'Failed to find characteristic ${BluetoothConstants.memoCharacteristicGuid}.';
    }
    statusUpdate('Found memo characteristic.');

    await _characteristic!.setNotifyValue(true);
    statusUpdate('Subscribed to notifications');
  }

  Future<T> _execute<T>(List<int> command, CommandProcessor processor) async {
    if (_characteristic == null) {
      throw "Not initialized, characteristic is missing.";
    }
    final valueSubscription = _characteristic!.onValueReceived.listen(
      processor.onData,
      onError: processor.onError,
    );
    device.cancelWhenDisconnected(valueSubscription);

    await _characteristic!.write(command, withoutResponse: true);

    try {
      final result = await processor.waitForResults();
      return result;
    } finally {
      valueSubscription.cancel();
    }
  }

  Future getConfig() async {
    return _execute([
      BluetoothConstants.commandConfigBlk,
    ], ConfigCommandProcessor());
  }

  Future<List<SensorEntry>> getMemoryData(
    int numEntries,
    Function(String) statusUpdate,
  ) async {
    final processor = MemoCommandProcessor(statusUpdate: statusUpdate);
    return _execute(BluetoothCommands.getMemoCommand(numEntries), processor);
  }

  Future<Duration> getDeviceTimeAndDrift() async {
    final processor = TimeCommandProcessor();
    return _execute(BluetoothCommands.getDeviceTime(), processor);
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
    device.disconnect();
  }
}
