import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mi_thermo_reader/services/bluetooth_manager.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
import 'package:mi_thermo_reader/utils/sensor_history.dart';
import 'package:mi_thermo_reader/widgets/error_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:icon_craft/icon_craft.dart';
import 'utils/sensor_entry.dart';
import 'widgets/sensor_chart.dart';

class DeviceScreen extends StatefulWidget {
  final KnownDevice device;
  late final String cacheKeyName;

  static const routeName = '/DeviceScreen';

  DeviceScreen({super.key, required this.device}) {
    cacheKeyName = device.bluetoothDevice.remoteId.str;
  }

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _isUpdatingData = false;
  final List<String> _statusUpdates = [];
  String? _error;
  SensorHistory? _sensorHistory;
  int lastNdaysFilter = -1;
  late final Future<SharedPreferencesWithCache> _preferences;
  late final BluetoothManager _bluetoothManager;

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
    _preferences = SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: <String>{widget.cacheKeyName},
      ),
    );

    try {
      _preferences.then((p) {
        final encodedEntries = p.getString(widget.cacheKeyName);
        if (encodedEntries == null) {
          log("No entries for device");
          return;
        }
        _sensorHistory = SensorHistory.from(encodedEntries);
        setState(() {
          _statusUpdates.add('Read $_sensorHistory from preferences.');
        });
      });
    } on ArgumentError {
      setState(() {
        _statusUpdates.add('No entries in preferences.');
      });
      if (_sensorHistory == null && kDebugMode) {
        _sensorHistory = SensorHistory(
          sensorEntries: _createFakeSensorData(2000),
        );
      }
    } catch (e) {
      setState(() {
        _statusUpdates.add('Failed loading entries from preferences: $e');
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
    try {
      // TODO(smoser): Are fetches below 50 not allowed?
      final int numEntries = math.max(
        50,
        _sensorHistory?.missingEntriesSince(DateTime.now()) ?? 5000,
      );
      await initBluetooth();
      final newEntries = await _bluetoothManager.getMemoryData(numEntries, (
        update,
      ) {
        _statusUpdates.add(update);
        if (mounted) {
          setState(() {});
        }
      });
      _sensorHistory = SensorHistory.createUpdated(_sensorHistory, newEntries);
      _statusUpdates.add('Got sensor history: $_sensorHistory');
      _preferences.then((p) {
        final encodedEntries = _sensorHistory!.toBase64ProtoString();
        p.setString(widget.cacheKeyName, encodedEntries);
      });
    } catch (e, trace) {
      _error = "Updating data failed: $e";
      log('Updating data failed: $e', stackTrace: trace);
    }
  }

  List<SensorEntry> _filteredSensorEntries() {
    if (_sensorHistory == null) {
      return [];
    }
    if (lastNdaysFilter == -1) {
      return _sensorHistory!.sensorEntries;
    }
    return _sensorHistory!.lastEntriesFrom(Duration(days: lastNdaysFilter));
  }

  Widget _makeDayFilterBar() {
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: _buildTitle(),
          actions: [
            IconButton(
              onPressed: () => getAndFixTime(),
              icon: IconCraft(
                Icon(Icons.schedule),
                Icon(Icons.healing),
                secondaryIconSizeFactor: 0.5,
                alignment: Alignment.bottomLeft,
                decoration: IconDecoration(
                  border: IconBorder(color: Theme.of(context).canvasColor),
                ),
              ),
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
                  _makeDayFilterBar(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    child:
                        _filteredSensorEntries().isEmpty
                            ? Text(
                              "No entries available, click [Update] to fetch data",
                            )
                            : SensorChart(
                              sensorEntries: _filteredSensorEntries(),
                            ),
                  ),
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
