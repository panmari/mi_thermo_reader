import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/services/bluetooth_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/sensor_entry.dart';
import 'widgets/sensor_chart.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;
  late final String cacheKeyName;

  static const routeName = '/DeviceScreen';

  DeviceScreen({super.key, required this.device}) {
    cacheKeyName = device.remoteId.str;
  }

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _isUpdatingData = false;
  final List<String> _statusUpdates = [];
  final List<SensorEntry> _sensorEntries = [];
  int lastNdaysFilter = -1;
  late final Future<SharedPreferencesWithCache> _preferences;
  late final BluetoothManager _bluetoothManager;

  List<SensorEntry> _createFakeSensorData(int nElements) {
    return List.generate(
      nElements,
      (i) => SensorEntry(
        index: i,
        timestamp: DateTime.now().subtract(
          Duration(minutes: (nElements - i) * 10),
        ),
        temperature: math.Random().nextDouble() * 2 + 21,
        humidity: 0,
        voltageBattery: 0,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _bluetoothManager = BluetoothManager(device: widget.device);
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
        _sensorEntries.addAll(SensorHistory.from(encodedEntries).sensorEntries);
        setState(() {
          _statusUpdates.add(
            'Read ${_sensorEntries.length} entries from preferences.',
          );
        });
      });
    } on ArgumentError {
      setState(() {
        _statusUpdates.add('No entries in preferences.');
      });
      if (_sensorEntries.isEmpty && kDebugMode) {
        _sensorEntries.addAll(_createFakeSensorData(2000));
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
    _sensorEntries.clear();
    _statusUpdates.clear();
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

  Future updateData() async {
    try {
      await _bluetoothManager.init((update) {
        _statusUpdates.add(update);
        if (mounted) {
          setState(() {});
        }
      });
      final newEntries = await _bluetoothManager.getMemoryData((update) {
        _statusUpdates.add(update);
        if (mounted) {
          setState(() {});
        }
      });
      _sensorEntries.addAll(newEntries);
      _preferences.then((p) {
        final encodedEntries =
            SensorHistory(sensorEntries: _sensorEntries).toBase64ProtoString();
        p.setString(widget.cacheKeyName, encodedEntries);
      });
    } catch (e, trace) {
      _statusUpdates.add("Updating data failed: $e");
      if (mounted) {
        setState(() {});
      }
      log('Updating data failed: $e', stackTrace: trace);
    }
  }

  List<SensorEntry> _filteredSensorEntries() {
    if (_sensorEntries.isEmpty) {
      return [];
    }
    if (lastNdaysFilter == -1) {
      return _sensorEntries;
    }
    final firstIncludedTimestamp = _sensorEntries.last.timestamp.subtract(
      Duration(days: lastNdaysFilter),
    );
    final firstIndex = _sensorEntries.indexWhere(
      (e) => e.timestamp.isAfter(firstIncludedTimestamp),
    );
    return _sensorEntries.sublist(firstIndex);
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: _buildTitle(),
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
                  _makeDayFilterBar(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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
