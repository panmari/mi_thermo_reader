import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/extra.dart';
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
  List<BluetoothService> _services = [];
  BluetoothService? _memoService;
  BluetoothCharacteristic? _memoCharacteristic;
  bool _isUpdatingData = false;
  final List<String> _statusUpdates = [];
  final List<SensorEntry> _sensorEntries = [];
  int lastNdaysFilter = -1;
  late final Future<SharedPreferencesWithCache> _preferences;

  StreamSubscription<List<int>>? _valueSubscription;

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
    _valueSubscription?.cancel();
    super.dispose();
  }

  void onUpdateDataPressed() {
    if (mounted) {
      setState(() {
        _isUpdatingData = true;
      });
    }
    updateData().then((e) {
      if (mounted) {
        setState(() {
          _isUpdatingData = false;
        });
      }
    });
  }

  Future updateData() async {
    _sensorEntries.clear();
    _statusUpdates.clear();
    if (mounted) {
      setState(() {
        _isUpdatingData = true;
      });
    }
    try {
      await widget.device.connectAndUpdateStream();
    } catch (e) {
      _statusUpdates.add("Connect Error: $e");
      return;
    }
    if (mounted) {
      setState(() {
        _statusUpdates.add("Connect: Success");
      });
    }
    try {
      _services = await widget.device.discoverServices(
        subscribeToServicesChanged: false,
      );
    } catch (e) {
      _statusUpdates.add("Discover Services Error: $e");
      return;
    }
    if (mounted) {
      setState(() {
        _statusUpdates.add("Discover Services: Success");
      });
    }
    try {
      // https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#bluetooth-connection-mode
      _memoService = _services.firstWhere(
        (service) => service.isPrimary && service.serviceUuid == Guid("1f10"),
      );
    } catch (e) {
      _statusUpdates.add("Could not find memo service in $_memoService");
      return;
    }
    // Inspired by https://pvvx.github.io/ATC_MiThermometer/GraphMemo.html.
    try {
      _memoCharacteristic = _memoService!.characteristics.firstWhere(
        (c) => c.characteristicUuid == Guid("1f1f"),
      );
    } catch (e) {
      _statusUpdates.add(
        "Could not find memo characteristic in ${_memoService!.characteristics}",
      );
      return;
    }
    if (mounted) {
      setState(() {
        _statusUpdates.add('Found memo characteristic');
      });
    }

    _valueSubscription = _memoCharacteristic!.onValueReceived.listen(
      processReceivedData,
    );
    widget.device.cancelWhenDisconnected(_valueSubscription!);

    try {
      // Subscribe to events.
      await _memoCharacteristic!.setNotifyValue(true);
    } catch (e) {
      _statusUpdates.add('Failed setNotifyValue: $e');
      return;
    }
    print("Past setting notifyValue");

    if (mounted) {
      setState(() {
        _statusUpdates.add('Subscribed to memo notifications');
      });
    }
    try {
      // Send command to read memory measures.
      // See https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#primary-service-uuid-0x1f10-characteristic-uuid-0x1f1f
      // The two parameters are:
      final lastNumMemo =
          5000; // How many records to fetch, starting with the most recent.
      final skipNumMemo = 0; // How many records to skip from the start.
      _memoCharacteristic!.write([
        0x35,
        lastNumMemo & 0xff,
        (lastNumMemo >> 8) & 0xff,
        skipNumMemo & 0xff,
        (skipNumMemo >> 8) & 0xff,
      ], withoutResponse: true);
    } catch (e) {
      _statusUpdates.add("Start get memo failed: $e");
      return;
    }
    _statusUpdates.add("Start get memo: Success");
  }

  void processReceivedData(List<int> values) {
    if (values.isEmpty) {
      return;
    }
    final data = ByteData.view(Uint8List.fromList(values).buffer);
    final blkid = data.getInt8(0);
    if (blkid != 0x35) {
      log("data with unexpected blkid $blkid: $data");
      return;
    }
    if (data.lengthInBytes >= 13) {
      // Got an entry from memory. Convert it to a SensorEntry.
      _sensorEntries.add(SensorEntry.parse(data));
      return;
    }
    if (data.lengthInBytes >= 3) {
      // They are sent in reverse chronological order, and might be received out of order.
      // Plus there might be retries. Be very defensive about keeping each value only once.
      _sensorEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final alreadyPresent = Set<DateTime>();
      _sensorEntries.retainWhere((e) => alreadyPresent.add(e.timestamp));
      if (mounted) {
        setState(() {
          _statusUpdates.add(
            'Done with reading. Got ${_sensorEntries.length} samples',
          );
          if (_sensorEntries.isNotEmpty) {
            _statusUpdates.add(
              'Last timestamp read: ${_sensorEntries.last.timestamp}',
            );
          }
        });
      }
      _preferences.then((p) {
        final encodedEntries =
            SensorHistory(sensorEntries: _sensorEntries).toBase64ProtoString();
        p.setString(widget.cacheKeyName, encodedEntries);
        setState(() {
          _isUpdatingData = false;
          _statusUpdates.add(
            'Saved ${_sensorEntries.length} entries to preferences.',
          );
        });
      });
      // Original code sets dev time here.
      // Disconnect here, we're done. Not using await, since the listener can't be async.
      widget.device.disconnect().then((_) {
        setState(() {
          _statusUpdates.add("Disconnected");
        });
      });
      return;
    }
    if (data.lengthInBytes == 2) {
      // TODO(panmari): This message seems pointless. Seems to be mostly 0 if received.
      final numSamples = data.getUint16(1, Endian.little);
      setState(() {
        _statusUpdates.add('Number of samples in memory: $numSamples');
      });
      return;
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
