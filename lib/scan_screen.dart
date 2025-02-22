import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_screen.dart';
import 'widgets/scan_result_tile.dart';
import 'utils/extra.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

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

  Future onScanPressed() async {
    // try {
    //   // `withServices` is required on iOS for privacy purposes, ignored on android.
    //   var withServices = [Guid("180f")]; // Battery Level Service
    //   _systemDevices = await FlutterBluePlus.systemDevices(withServices);
    // } catch (e) {
    //   print(e);
    // }
    try {
      // https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#control-function-id-when-connected;
      // Note that using those as service list does not work.
      var optionalServices = [Guid("fe95"), Guid("181a"), Guid("1f10")];
      var withTemperaturServiceData = [ServiceDataFilter(Guid("fcd2"))];
      await FlutterBluePlus.startScan(
        withServiceData: withTemperaturServiceData,
        // webOptionalServices: optionalServices,
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      print(e);
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
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => DeviceScreen(device: device),
      settings: RouteSettings(name: '/DeviceScreen'),
    );
    Navigator.of(context).push(route);
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      // key: Snackbar.snackBarKeyB,
      child: Scaffold(
        appBar: AppBar(title: const Text('Find Devices')),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[..._buildScanResultTiles(context)],
          ),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
