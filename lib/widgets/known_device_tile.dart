import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_thermo_reader/device_screen.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';

class KnownDeviceTile extends ConsumerWidget {
  final KnownDevice device;

  const KnownDeviceTile({required this.device, super.key});

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
                  Icon(Icons.telegram, size: 50.0),
                  SizedBox(height: 8.0),
                  Text(_bestName()),
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
