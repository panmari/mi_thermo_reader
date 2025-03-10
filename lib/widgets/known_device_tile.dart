import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/device_screen.dart';

class KnownDeviceTile extends StatefulWidget {
  final BluetoothDevice device;

  const KnownDeviceTile({required this.device, super.key});

  @override
  State<KnownDeviceTile> createState() => _KnownDeviceTileState();
}

class _KnownDeviceTileState extends State<KnownDeviceTile> {
  @override
  void initState() {
    super.initState();
  }

  String _bestName() {
    if (widget.device.advName.isNotEmpty) {
      return widget.device.advName;
    }
    if (widget.device.platformName.isNotEmpty) {
      return widget.device.platformName;
    }
    return widget.device.remoteId.str;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Icon(Icons.telegram, size: 50.0),
            Text(_bestName()),
            ElevatedButton(
              onPressed:
                  () => Navigator.of(
                    context,
                  ).pushNamed(DeviceScreen.routeName, arguments: widget.device),
              child: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }
}
