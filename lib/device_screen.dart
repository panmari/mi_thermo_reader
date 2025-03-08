import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/snackbar.dart';
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
  int? _rssi;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  BluetoothService? _memoService;
  BluetoothCharacteristic? _memoCharacteristic;
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  final List<String> _statusUpdates = [];
  final List<SensorEntry> _sensorEntries = [];
  late final Future<SharedPreferencesWithCache> _preferences;

  late StreamSubscription<BluetoothConnectionState>
  _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<List<int>> _valueSubscription;

  @override
  void initState() {
    super.initState();
    _preferences = SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(
        allowList: <String>{widget.cacheKeyName},
      ),
    );
    _connectionStateSubscription = widget.device.connectionState.listen((
      state,
    ) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }
      if (mounted) {
        setState(() {});
      }
    });

    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isDisconnectingSubscription = widget.device.isDisconnecting.listen((
      value,
    ) {
      _isDisconnecting = value;
      if (mounted) {
        setState(() {});
      }
    });

    try {
      _preferences.then((p) {
        final encodedEntries = p.getString(widget.cacheKeyName);
        if (encodedEntries != null) {
          _sensorEntries.addAll(
            SensorHistory.from(encodedEntries).sensorEntries,
          );
          setState(() {
            _statusUpdates.add(
              'Read ${_sensorEntries.length} entries from preferences.',
            );
          });
        }
      });
    } on ArgumentError {
      setState(() {
        _statusUpdates.add('No entries in preferences.');
      });
    } catch (e) {
      setState(() {
        _statusUpdates.add('Failed loading entries from preferences: $e');
      });
    }
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    _valueSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  Future onConnectPressed() async {
    try {
      await widget.device.connectAndUpdateStream();
      Snackbar.show(ABC.c, "Connect: Success", success: true);
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        Snackbar.show(
          ABC.c,
          prettyException("Connect Error:", e),
          success: false,
        );
        print(e);
      }
    }
  }

  Future onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
      Snackbar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false);
      print(e);
    }
  }

  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream();
      Snackbar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e) {
      Snackbar.show(
        ABC.c,
        prettyException("Disconnect Error:", e),
        success: false,
      );
      print(e);
    }
  }

  Future onDiscoverServicesPressed() async {
    _sensorEntries.clear();
    _statusUpdates.clear();
    if (mounted) {
      setState(() {
        _isDiscoveringServices = true;
      });
    }
    try {
      _services = await widget.device.discoverServices(
        subscribeToServicesChanged: false,
      );
      _statusUpdates.add("Discover Services: Success");
      Snackbar.show(ABC.c, "Discover Services: Success", success: true);
    } catch (e) {
      Snackbar.show(
        ABC.c,
        prettyException("Discover Services Error:", e),
        success: false,
      );
      _statusUpdates.add("Discover Services Error: $e");
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isDiscoveringServices = false;
        });
      }
    }

    try {
      // https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#bluetooth-connection-mode
      _memoService = _services.firstWhere(
        (service) => service.isPrimary && service.serviceUuid == Guid("1f10"),
      );
    } catch (e) {
      print("Could not find memo service: $e");
      return;
    }
    // Inspired by https://pvvx.github.io/ATC_MiThermometer/GraphMemo.html.
    try {
      _memoCharacteristic = _memoService!.characteristics.firstWhere(
        (c) => c.characteristicUuid == Guid("1f1f"),
      );
    } catch (e) {
      print("Could not find memo characteristic: $e");
      return;
    }
    if (mounted) {
      setState(() {
        _statusUpdates.add(
          'Found characteristic, properties: ${_memoCharacteristic!.properties}',
        );
      });
    }

    _valueSubscription = _memoCharacteristic!.onValueReceived.listen((v) {
      if (v.isEmpty) {
        return;
      }
      final data = ByteData.view(Uint8List.fromList(v).buffer);
      final blkid = data.getInt8(0);
      if (blkid == 0x35) {
        if (v.length >= 13) {
          // Got an entry from memory. Convert it to a SensorEntry.
          _sensorEntries.add(SensorEntry.parse(data));
          return;
        }
        if (v.length >= 3) {
          if (mounted) {
            setState(() {
              _statusUpdates.add(
                'Done with reading. Got ${_sensorEntries.length} samples',
              );
            });
          }
          _preferences.then((p) {
            final encodedEntries =
                SensorHistory(
                  sensorEntries: _sensorEntries,
                ).toBase64ProtoString();
            p.setString(widget.cacheKeyName, encodedEntries);
            setState(() {
              _statusUpdates.add(
                'Saved ${_sensorEntries.length} entries to preferences.',
              );
            });
          });
          // Set dev time
          return;
        }
        if (v.length == 2) {
          final numSamples = data.getUint16(1, Endian.little);
          setState(() {
            _statusUpdates.add('Number of samples in memory: $numSamples');
          });
          return;
        }
      }
      if (blkid == 0x23 && v.length >= 4) {
        print("blkid 23");
        // Log device time, then disconnect
        return;
      }
      if (blkid == 0x55) {
        // Received device config.
        // Send command to read memory measures.
        // See https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#primary-service-uuid-0x1f10-characteristic-uuid-0x1f1f
        print(v);
        final numMemo = 5000;
        final start = 0; // TODO(panmari): Figure out  how this affects getMemo.
        _statusUpdates.add('Sending command getMemo');
        try {
          _memoCharacteristic!.write([
            0x35,
            numMemo & 0xff,
            (numMemo >> 8) & 0xff,
            start & 0xff,
            (start >> 8) & 0xff,
          ], withoutResponse: true);
        } catch (e) {
          print("Failed get-memo $e");
        }
        return;
      }
    });
    widget.device.cancelWhenDisconnected(_valueSubscription);

    try {
      // Subscribe to events. Two surprising facts:
      // 1. No await needed, in all my testing this took affect in time.
      // 2. The code might time out, but things still work.
      await _memoCharacteristic!.setNotifyValue(true, timeout: 5);
    } catch (e) {
      setState(() {
        _statusUpdates.add('Failed setNotifyValue: $e');
      });
    }
    print("Past setting notifyValue");

    if (mounted) {
      setState(() {
        _statusUpdates.add('Sent command getDeviceConfig');
      });
    }
    try {
      // Send command to read device config
      // See https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#primary-service-uuid-0x1f10-characteristic-uuid-0x1f1f
      await _memoCharacteristic!.write([0x55], withoutResponse: true);
    } catch (e) {
      setState(() {
        _statusUpdates.add("Getting device config failed: $e");
      });
      return;
    }
    setState(() {
      _statusUpdates.add("Got device config.");
    });
  }

  Widget buildSpinner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: AspectRatio(aspectRatio: 1.0, child: CircularProgressIndicator()),
    );
  }

  Widget buildRemoteId(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('${widget.device.remoteId}'),
    );
  }

  Widget buildRssiTile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isConnected
            ? const Icon(Icons.bluetooth_connected)
            : const Icon(Icons.bluetooth_disabled),
        Text(
          ((isConnected && _rssi != null) ? '${_rssi!} dBm' : ''),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget buildGetServices(BuildContext context) {
    return IndexedStack(
      index: (_isDiscoveringServices) ? 1 : 0,
      children: <Widget>[
        TextButton(
          onPressed: onDiscoverServicesPressed,
          child: const Text("Get Services"),
        ),
        const IconButton(
          icon: SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(),
          ),
          onPressed: null,
        ),
      ],
    );
  }

  Widget buildConnectButton(BuildContext context) {
    return Row(
      children: [
        if (_isConnecting || _isDisconnecting) buildSpinner(context),
        TextButton(
          onPressed:
              _isConnecting
                  ? onCancelPressed
                  : (isConnected ? onDisconnectPressed : onConnectPressed),
          child: Text(
            _isConnecting ? "CANCEL" : (isConnected ? "DISCONNECT" : "CONNECT"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyC,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.platformName),
          actions: [buildConnectButton(context)],
        ),
        body: SingleChildScrollView(
          child: Column(
            children:
                <Widget>[
                  buildRemoteId(context),
                  ListTile(
                    leading: buildRssiTile(context),
                    title: Text(
                      'Device is ${_connectionState.toString().split('.')[1]}',
                    ),
                    subtitle: buildGetServices(context),
                  ),
                  SensorChart(sensorEntries: _sensorEntries),
                ] +
                _statusUpdates.map((e) => Text(e)).toList(),
          ),
        ),
      ),
    );
  }
}
