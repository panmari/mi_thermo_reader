import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SystemDeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  final VoidCallback onOpen;

  const SystemDeviceTile({
    required this.device,
    required this.onOpen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.platformName),
      subtitle: Text(device.remoteId.str),
      leading: Icon(Icons.computer),
      trailing: ElevatedButton(onPressed: onOpen, child: const Text('Open')),
    );
  }
}
