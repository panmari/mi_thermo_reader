import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanResultTile extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onTap;

  const ScanResultTile({super.key, required this.result, required this.onTap});

  Widget _buildTitle(BuildContext context) {
    if (result.device.platformName.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(result.device.platformName, overflow: TextOverflow.ellipsis),
          Text(
            result.device.remoteId.str,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    } else {
      return Text(result.device.remoteId.str);
    }
  }

  Widget _buildConnectButton(BuildContext context) {
    return ElevatedButton(
      onPressed: (result.advertisementData.connectable) ? onTap : null,
      child: const Text('Open'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: _buildConnectButton(context),
    );
  }
}
