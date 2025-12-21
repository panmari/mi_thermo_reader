import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_thermo_reader/device_screen.dart';
import 'package:mi_thermo_reader/services/bluetooth_advertisement_parsers/thermometer_advertisement.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';

class KnownDeviceTile extends ConsumerWidget {
  final KnownDevice device;
  final AdvertisementData? advertisementData;

  const KnownDeviceTile({
    required this.device,
    this.advertisementData,
    super.key,
  });

  String _bestName() {
    if (device.advName.isNotEmpty) {
      return device.advName;
    }
    if (device.platformName.isNotEmpty) {
      return device.platformName;
    }
    return device.remoteId;
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete "${_bestName()}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future _maybeRemoveKnownDevice(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete == null || !shouldDelete) {
      return;
    }

    return KnownDevice.remove(ref, device);
  }

  Widget _advertisementDataRow() {
    if (advertisementData == null) {
      return SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(),
      );
    }
    try {
      final advertisement = ThermometerAdvertisement.create(advertisementData!);
      return Text(
        'Temperature: ${advertisement.temperature}°C, Humidity: ${advertisement.humidity}%',
      );
    } catch (e) {
      log('Failed to parse advertisement data: $e');
      return Text('Advertisement data: Not parsable');
    }
    // TODO(panmari): Add handling for when scanning ended and no data is available.
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.device_thermostat, size: 50.0),
                  SizedBox(height: 8.0),
                  Text(_bestName()),
                  SizedBox(height: 8.0),
                  _advertisementDataRow(),
                  SizedBox(height: 8.0),
                  OutlinedButton(
                    onPressed:
                        () => Navigator.of(
                          context,
                        ).pushNamed(DeviceScreen.routeName, arguments: device),
                    child: const Text('Open'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0.0,
            right: 0.0,
            child: IconButton(
              onPressed: () async {
                await _maybeRemoveKnownDevice(context, ref);
              },
              icon: Icon(Icons.close, size: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}
