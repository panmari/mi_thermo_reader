import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_thermo_reader/device_screen.dart';
import 'package:mi_thermo_reader/home_page.dart';
import 'package:mi_thermo_reader/scan_screen.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';
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
  if (kDebugMode) {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  }
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
          final device = settings.arguments as KnownDevice;
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
