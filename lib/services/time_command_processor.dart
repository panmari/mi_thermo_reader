import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:mi_thermo_reader/services/bluetooth_constants.dart';

class TimeCommandProcessor {
  final done = Completer<Duration>();

  DateTime _toDateTime(int timestampSeconds) {
    return DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000);
  }

  void onData(List<int> values) {
    if (values.isEmpty) {
      return;
    }
    final data = ByteData.view(Uint8List.fromList(values).buffer);
    final blkid = data.getInt8(0);
    if (blkid != BluetoothConstants.commandTimeBlk) {
      log("time response unexpected blkid $blkid: $values");
      return;
    }
    if (data.lengthInBytes < 5) {
      log(
        "time response with unexpected length ${data.lengthInBytes}: $values",
      );
    }
    final deviceTime = _toDateTime(data.getUint32(1, Endian.little));
    if (data.lengthInBytes >= 8) {
      final lastSetTime = _toDateTime(data.getUint32(5, Endian.little));

      final durationOnDevice = deviceTime.difference(lastSetTime);
      final durationReal = DateTime.now().difference(lastSetTime);

      final deviceTimeDrift = durationOnDevice - durationReal;

      log(
        'Time on device: $deviceTime, last set: $lastSetTime. Drift: $deviceTimeDrift',
      );
      done.complete(deviceTimeDrift);
    }
  }

  void onError(Object error, StackTrace trace) {
    done.completeError(error, trace);
  }

  Future<Duration> waitForResults() {
    return done.future;
  }
}
