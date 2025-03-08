import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/device_screen.dart';
import 'package:mi_thermo_reader/utils/known_devices.dart';
import 'package:mi_thermo_reader/widgets/system_device_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'scan_screen.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(
    Provider<Future<SharedPreferencesWithCache>>(
      create:
          (_) => SharedPreferencesWithCache.create(
            cacheOptions: SharedPreferencesWithCacheOptions(
              allowList: <String>{KnownDevices.cacheKey},
            ),
          ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Thermometer Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
      ),
      home: const MiThermoReaderHomePage(),
      navigatorObservers: [BluetoothAdapterStateObserver()],

      onGenerateRoute: (settings) {
        if (settings.name == DeviceScreen.routeName) {
          final device = settings.arguments as BluetoothDevice;
          return MaterialPageRoute(
            builder: (context) {
              return DeviceScreen(device: device);
            },
          );
        }
        if (settings.name == ScanScreen.routeName) {
          return MaterialPageRoute(builder: (context) => ScanScreen());
        }

        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

class MiThermoReaderHomePage extends StatefulWidget {
  const MiThermoReaderHomePage({super.key});

  @override
  State<MiThermoReaderHomePage> createState() => _MiThermoReaderHomePageState();
}

class _MiThermoReaderHomePageState extends State<MiThermoReaderHomePage> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  final List<BluetoothDevice> _knownDevices = [];

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

    KnownDevices.getKnownDevices(context).then((loadedDevices) {
      setState(() {
        _knownDevices.addAll(loadedDevices);
      });
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  Widget _centerContent() {
    if (_adapterState == BluetoothAdapterState.on) {
      if (_knownDevices.isEmpty) {
        return const Text('Start by adding devices by clicking on +');
      }
      return ListView(
        children:
            _knownDevices
                .map(
                  (d) => SystemDeviceTile(
                    device: d,
                    onOpen:
                        () => Navigator.of(
                          context,
                        ).pushNamed(DeviceScreen.routeName, arguments: d),
                    onConnect: () => log('woops'),
                  ),
                )
                .toList(),
      );
    }
    return Text(
      'Bluetooth adapter state is ${_adapterState.name}, please enable.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Mi Thermometer Reader"),
      ),
      body: _centerContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, ScanScreen.routeName);
        },
        tooltip: 'Scan for devices',
        child: const Icon(Icons.add),
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
