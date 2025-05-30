import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/services/bluetooth_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
import 'package:mi_thermo_reader/widgets/error_message.dart';

import 'device_screen.dart';
import 'widgets/scan_result_tile.dart';
import 'widgets/system_device_tile.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  static const routeName = '/ScanScreen';

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  String? _error;
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
      onError: (e, trace) {
        log('Subscription got an error: $e', stackTrace: trace);
        _error = e.toString();
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
    FlutterBluePlus.stopScan();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  List<Guid> optionalServices() {
    if (kIsWeb) {
      // https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#control-function-id-when-connected;
      // Note that using those as service list does not work.
      // If this is specified on Android, the plugin throws an exception.
      return [BluetoothConstants.memoServiceGuid];
    }
    return [];
  }

  Future onScanPressed() async {
    _error = null;
    try {
      // `withServices` is required on iOS for privacy purposes, ignored on android.
      var withServices = [BluetoothConstants.memoServiceGuid];
      _systemDevices = await FlutterBluePlus.systemDevices(withServices);
    } catch (e, trace) {
      _error = 'Retrieving system devices failed: $e';
      log("Retrieving system devices failed: $e", stackTrace: trace);
    }
    try {
      await FlutterBluePlus.startScan(
        // withServices does not work on Android, the service is not advertised.
        // withServices: [BluetoothConstants.memoServiceGuid],
        // withServiceData works, but there's multiple formats for advertising.
        // withServiceData [ServiceDataFilter(BluetoothConstants.btHomeReversedGuid)]
        webOptionalServices: optionalServices(),
        timeout: const Duration(seconds: 15),
      );
    } catch (e, trace) {
      _error = 'Start scan failed: $e';
      log("Start scan failed: $e", stackTrace: trace);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void onOpenPressed(BluetoothDevice btDevice) {
    KnownDevice.add(ref, btDevice).then((_) {
      log('Added to $btDevice known devices');
    });
    Navigator.of(
      context,
    ).pushNamed(DeviceScreen.routeName, arguments: KnownDevice.from(btDevice));
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

  Widget _buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return SizedBox();
    } else {
      return FloatingActionButton(
        onPressed: onScanPressed,
        child: const Icon(Icons.bluetooth_searching),
      );
    }
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) =>
              ScanResultTile(result: r, onTap: () => onOpenPressed(r.device)),
        )
        .toList();
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map((d) => SystemDeviceTile(device: d, onOpen: () => onOpenPressed(d)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: _isScanning ? LinearProgressIndicator() : SizedBox(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: <Widget>[
            _error != null ? ErrorMessage(message: _error!) : SizedBox(),
            ..._buildSystemDeviceTiles(context),
            ..._buildScanResultTiles(context),
          ],
        ),
      ),
      floatingActionButton: _buildScanButton(context),
    );
  }
}
