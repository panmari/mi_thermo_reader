import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mi_thermo_reader/device_screen.dart';
import 'package:mi_thermo_reader/utils/known_device.dart';

class KnownDeviceTile extends StatefulWidget {
  final KnownDevice device;

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
    return widget.device.remoteId;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
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
                        () => Navigator.of(context).pushNamed(
                          DeviceScreen.routeName,
                          arguments: BluetoothDevice.fromId(
                            widget.device.remoteId,
                          ),
                        ),
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
              onPressed: () => 'nothing',
              icon: Icon(Icons.close, size: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}
