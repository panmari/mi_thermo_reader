import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_thermo_reader/device_screen.dart';
import 'package:mi_thermo_reader/scan_screen.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
import 'package:mi_thermo_reader/widgets/error_message.dart';
import 'package:mi_thermo_reader/widgets/known_device_tile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'main.g.dart';

@riverpod
Future<SharedPreferencesWithCache> fetchSharedPreferences(Ref ref) {
  return SharedPreferencesWithCache.create(
    // Allowlist needs to be null because device IDs are used as cache keys.
    // Device IDs are not available when the cache is constructed here.
    cacheOptions: SharedPreferencesWithCacheOptions(allowList: null),
  );
}

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Thermometer Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
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

  Widget _centerContent() {
    final knownDevices = KnownDevice.getAll(ref);
    if (knownDevices.isNotEmpty) {
      return ListView(
        children: knownDevices.map((d) => KnownDeviceTile(device: d)).toList(),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _centerContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            _adapterState == BluetoothAdapterState.off
                ? null
                : () {
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
