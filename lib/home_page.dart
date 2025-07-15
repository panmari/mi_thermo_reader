import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/scan_screen.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
import 'package:mi_thermo_reader/widgets/error_message.dart';
import 'package:mi_thermo_reader/widgets/known_device_tile.dart';
import 'package:mi_thermo_reader/widgets/popup_menu.dart';

class MiThermoReaderHomePage extends ConsumerStatefulWidget {
  const MiThermoReaderHomePage({super.key});

  @override
  ConsumerState<MiThermoReaderHomePage> createState() =>
      _MiThermoReaderHomePageState();
}

class _MiThermoReaderHomePageState
    extends ConsumerState<MiThermoReaderHomePage> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((
      state,
    ) {
      if (mounted) {
        setState(() {
          _adapterState = state;
        });
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  Widget _addDeviceCard() {
    if (_adapterState == BluetoothAdapterState.off) {
      return Container();
    }
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.add, size: 50.0),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed:
                    () => Navigator.pushNamed(context, ScanScreen.routeName),
                child: const Text('Add device'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerContent() {
    final knownDevices = KnownDevice.getAll(ref);
    if (knownDevices.isNotEmpty) {
      return ListView(
        children:
            knownDevices
                .map((d) => KnownDeviceTile(device: d))
                .toList()
                .cast<Widget>() +
            [_addDeviceCard()],
      );
    }
    switch (_adapterState) {
      case BluetoothAdapterState.on:
        return const Text('Start by adding devices by clicking on +');
      case BluetoothAdapterState.off:
        return ErrorMessage(
          message:
              'Bluetooth adapter state is ${_adapterState.name}, please enable.',
        );
      default:
        return Text(
          'Bluetooth adapter state is ${_adapterState.name}',
          textAlign: TextAlign.center,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Mi Thermometer Reader"),
        actions: [PopupMenu()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _centerContent(),
      ),
    );
  }
}

// This observer listens for Bluetooth Off and dismisses the DeviceScreen
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((
        state,
      ) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
