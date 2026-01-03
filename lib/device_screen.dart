import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_thermo_reader/services/bluetooth_manager.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
import 'package:mi_thermo_reader/utils/sensor_history.dart';
import 'package:mi_thermo_reader/widgets/error_message.dart';
import 'package:mi_thermo_reader/widgets/popup_menu.dart';
import 'package:region_settings/region_settings.dart';
import 'utils/sensor_entry.dart';
import 'widgets/sensor_chart.dart';

class DeviceScreen extends ConsumerStatefulWidget {
  final KnownDevice device;

  static const routeName = '/DeviceScreen';

  const DeviceScreen({super.key, required this.device});

  @override
  ConsumerState<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends ConsumerState<DeviceScreen> {
  bool _isUpdatingData = false;
  final List<String> _statusUpdates = [];
  String? _error;
  int lastNdaysFilter = -1;
  late final BluetoothManager _bluetoothManager;
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;

  List<SensorEntry> _createFakeSensorData(int nElements) {
    double lastTemp = 21.0;
    double lastHum = 51.0;
    return List.generate(nElements, (i) {
      lastTemp += math.Random().nextDouble() * 0.1 - 0.05;
      lastHum += math.Random().nextDouble() - 0.5;
      return SensorEntry(
        index: i,
        timestamp: DateTime.now().subtract(
          Duration(minutes: (nElements - i) * 10),
        ),
        temperature: lastTemp,
        humidity: lastHum,
        voltageBattery: 0,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _bluetoothManager = BluetoothManager(device: widget.device.bluetoothDevice);
    if (!kIsWeb) {
      // Package only supports non-web platforms.
      RegionSettings.getSettings().then((settings) {
        _temperatureUnit = settings.temperatureUnits;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _bluetoothManager.dispose();
  }

  void onUpdateDataPressed() {
    _error = null;
    _isUpdatingData = true;
    if (mounted) {
      setState(() {});
    }
    updateData().then((e) {
      _isUpdatingData = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future initBluetooth() async {
    await _bluetoothManager.init((update) {
      _statusUpdates.add(update);
      if (mounted) {
        setState(() {});
      }
    });
  }

  void getAndFixTime() async {
    _error = null;
    try {
      await initBluetooth();
      final drift = await _bluetoothManager.getDeviceTimeAndDrift();
      _statusUpdates.add("Device time drift: $drift");

      await _bluetoothManager.setDeviceTimeToNow();
      _statusUpdates.add("Successfully updated time.");
    } catch (e, trace) {
      _error = "Get time failed: $e";
      log('Get time failed: $e', stackTrace: trace);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future updateData() async {
    final cachedSensorHistory =
        widget.device.getCachedSensorHistory(ref) ??
        SensorHistory(sensorEntries: []);

    try {
      final int numEntries = cachedSensorHistory.missingEntriesSince(
        DateTime.now(),
      );
      if (numEntries == 0) {
        _statusUpdates.add('No missing entries.');
        if (mounted) {
          setState(() {});
        }
        return;
      }
      try {
        await initBluetooth();
      } catch (e, trace) {
        _error = "Bluetooth initialization failed: $e";
        log('Bluetooth initialization failed: $e', stackTrace: trace);
        return;
      }
      // Get config first to wake up device. If this is not done, getMemoryData
      // occasionally only returns partial data.
      try {
        await _bluetoothManager.getConfig();
      } on TimeoutException {
        _statusUpdates.add('Get config timed out, ignoring...');
      }
      List<SensorEntry> newEntries = [];
      try {
        newEntries = await _bluetoothManager.getMemoryData(numEntries, (
          update,
        ) {
          _statusUpdates.add(update);
          if (mounted) {
            setState(() {});
          }
        });
      } on TimeoutException {
        _error = "Timeout while getting data. Move closer to the device.";
        return;
      }
      final updatedSensorHistory = SensorHistory.createUpdated(
        cachedSensorHistory,
        newEntries,
      );
      _statusUpdates.add('Updated sensor history: $updatedSensorHistory');
      widget.device.setCachedSensorHistory(ref, updatedSensorHistory);
    } catch (e, trace) {
      _error = "Updating data failed: $e";
      log('Updating data failed: $e', stackTrace: trace);
    }
  }

  List<SensorEntry> _filter(SensorHistory? history) {
    if (history == null) {
      return [];
    }
    if (lastNdaysFilter == -1) {
      return history.sensorEntries;
    }
    return history.lastEntriesFrom(Duration(days: lastNdaysFilter));
  }

  Widget _buildDayFilterBar() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: DayFilterOption.values.length,
        itemBuilder: (context, index) {
          final option = DayFilterOption.values[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(option.label),
              selected: lastNdaysFilter == option.numDays,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    lastNdaysFilter = option.numDays;
                  });
                }
              },
            ),
          );
        },
        padding: EdgeInsets.all(5),
      ),
    );
  }

  Widget _buildTitle() {
    final res = StringBuffer();
    if (widget.device.platformName.isNotEmpty) {
      res.write(widget.device.platformName);
    } else {
      res.write("N/A");
    }
    res.write(', (${widget.device.remoteId})');
    return Text(res.toString());
  }

  Widget _buildErrorMessage() {
    if (_error == null) {
      return SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ErrorMessage(message: _error!),
    );
  }

  Widget _buildBatteryBar(SensorHistory? sensorHistory) {
    final lastEntry = sensorHistory?.sensorEntries.lastOrNull;
    if (lastEntry == null || lastEntry.voltageBattery <= 0) {
      return const SizedBox();
    }
    return Text("Battery: ${lastEntry.batteryPercentage.toStringAsFixed(0)}%");
  }

  Future<void> _deleteSensorEntries() async {
    final history = widget.device.getCachedSensorHistory(ref);
    if (history == null || history.sensorEntries.isEmpty) {
      return;
    }

    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: history.sensorEntries.first.timestamp,
      lastDate: history.sensorEntries.last.timestamp,
      helpText: 'Select date range to delete',
      saveText: 'Delete',
    );

    if (dateRange != null) {
      final updatedHistory = history.copyWithEntriesFiltered(
        dateRange.start,
        dateRange.end,
      );
      widget.device.setCachedSensorHistory(ref, updatedHistory);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SensorHistory? cachedSensorHistory = widget.device.getCachedSensorHistory(
      ref,
    );
    if (cachedSensorHistory == null && kDebugMode) {
      cachedSensorHistory = SensorHistory(
        sensorEntries: _createFakeSensorData(2000),
      );
    }
    final filteredSensorEntries = _filter(cachedSensorHistory);
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: _buildTitle(),
          actions: [
            PopupMenu(
              getAndFixTime: getAndFixTime,
              deleteSensorEntries: _deleteSensorEntries,
              sensorEntries: filteredSensorEntries,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: _isUpdatingData ? LinearProgressIndicator() : SizedBox(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isUpdatingData ? null : onUpdateDataPressed,
          tooltip: "Updates data by connecting to the device.",
          child: Icon(Icons.update),
        ),
        body: SingleChildScrollView(
          child: Column(
            children:
                <Widget>[
                  _buildErrorMessage(),
                  _buildDayFilterBar(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    child:
                        filteredSensorEntries.isEmpty
                            ? Text(
                              "No entries available, click [Update] to fetch data",
                            )
                            : SensorChart(
                              sensorEntries: filteredSensorEntries,
                              temperatureUnit: _temperatureUnit,
                            ),
                  ),
                  _buildBatteryBar(cachedSensorHistory),
                ] +
                _statusUpdates.map((e) => Text(e)).toList(),
          ),
        ),
      ),
    );
  }
}

enum DayFilterOption {
  all(numDays: -1, label: 'All'),
  lastDay(numDays: 1, label: 'last day'),
  oneWeek(numDays: 7, label: '7 days'),
  oneMonth(numDays: 30, label: '30 days');

  final int numDays;
  final String label;

  const DayFilterOption({required this.numDays, required this.label});
}
