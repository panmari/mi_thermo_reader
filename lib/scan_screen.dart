import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_screen.dart';
import 'widgets/scan_result_tile.dart';
import 'widgets/system_device_tile.dart';
import 'utils/extra.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  static const routeName = '/ScanScreen';

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        _scanResults = results;
        if (mounted) {
          setState(() {});
        }
      },
      onError: (e) {
        print(e);
        // Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
      },
    );

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  List<Guid> optionalServices() {
    if (kIsWeb) {
      // https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#control-function-id-when-connected;
      // Note that using those as service list does not work.
      // If this is specified on Android, the plugin throws an exception.
      return  [Guid("181a"), Guid("1f10")];
    }
    return [];
  }

  List<ServiceDataFilter> withServiceData() {
    if (kIsWeb) {
      // Causes 'Failed to execute 'requestDevice' on 'Bluetooth'' on web. 
      return [];
    }
    return [ServiceDataFilter(Guid("fcd2"))];
  }

  Future onScanPressed() async {
    try {
      // `withServices` is required on iOS for privacy purposes, ignored on android.
      var withServices = [Guid("1f10")]; // Temperature history service.
      _systemDevices = await FlutterBluePlus.systemDevices(withServices);
    } catch (e) {
      print("Retrieving system devices failed: $e");
    }
    try {
      await FlutterBluePlus.startScan(
        withServiceData: withServiceData(),
        webOptionalServices: optionalServices(),
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      print("Start scan failed: $e");
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      print(e);
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      log("Connect error: $e");
      // Snackbar.show(
      //   ABC.c,
      //   prettyException("Connect Error:", e),
      //   success: false,
      // );
    });
    Navigator.of(context).pushNamed(DeviceScreen.routeName, arguments: device);
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
        onPressed: onScanPressed,
        child: const Text("SCAN"),
      );
    }
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DeviceScreen(device: d),
                    settings: RouteSettings(name: '/DeviceScreen'),
                  ),
                ),
            onConnect: () => onConnectPressed(d),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      // key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(title: const Text('Find Devices')),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              ..._buildSystemDeviceTiles(context),
              ..._buildScanResultTiles(context),
            ],
          ),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
