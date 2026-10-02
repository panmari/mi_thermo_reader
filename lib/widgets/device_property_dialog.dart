import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DevicePropertyDialog extends StatefulWidget {
  final BluetoothDevice device;

  const DevicePropertyDialog({super.key, required this.device});

  @override
  State<DevicePropertyDialog> createState() => _DevicePropertyDialogState();
}

class _DevicePropertyDialogState extends State<DevicePropertyDialog> {
  bool _isUtc = false;

  @override
  Widget build(BuildContext context) {
    final deviceName = widget.device.platformName.isNotEmpty
        ? widget.device.platformName
        : widget.device.advName.isNotEmpty
            ? widget.device.advName
            : widget.device.remoteId.str;

    return AlertDialog(
      title: Text('Connect to $deviceName'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select the timestamp format used by this sensor:'),
          const SizedBox(height: 12),
          RadioGroup<bool>(
            groupValue: _isUtc,
            onChanged: (val) => setState(() => _isUtc = val ?? false),
            child: Column(
              children: const [
                RadioListTile<bool>(
                  title: Text('Local Time'),
                  subtitle: Text('Sensor timestamps are in local time'),
                  value: false,
                ),
                RadioListTile<bool>(
                  title: Text('UTC'),
                  subtitle: Text('Sensor timestamps are in UTC'),
                  value: true,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_isUtc),
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
