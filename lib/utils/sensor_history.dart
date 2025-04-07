import 'package:mi_thermo_reader/src/proto/model.pb.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:proto_annotations/proto_annotations.dart';
import 'package:stats/stats.dart';

part 'sensor_history.g.dart';

@proto
class SensorHistory {
  @ProtoField(2)
  final List<SensorEntry> sensorEntries;
  late final Stats<int> _intervalStats;

  SensorHistory({required this.sensorEntries}) {
    if (sensorEntries.length < 2) {
      // Initialize with a reasonable default to avoid null handling.
      _intervalStats = Stats(0, 0, 0, 0, 0, 0);
      return;
    }
    List<int> intervalInSeconds = [];
    for (int i = 0; i < sensorEntries.length - 1; i++) {
      DateTime current = sensorEntries[i].timestamp;
      DateTime next = sensorEntries[i + 1].timestamp;

      Duration intervalDuration = next.difference(current);

      intervalInSeconds.add(intervalDuration.inSeconds);
    }

    _intervalStats = Stats.fromData(intervalInSeconds);
  }

  static SensorHistory from(String base64ProtoString) {
    final buffer = base64Decode(base64ProtoString);
    return GSensorHistory.fromBuffer(buffer).toSensorHistory();
  }

  String toBase64ProtoString() {
    return base64Encode(toProto().writeToBuffer());
  }

  // Returns entries in the time range [last.timestamp - duration, last.timestamp].
  List<SensorEntry> lastEntriesFrom(Duration duration) {
    final firstIncludedTimestamp = sensorEntries.last.timestamp.subtract(
      duration,
    );
    final firstIndex = sensorEntries.indexWhere(
      (e) => e.timestamp.isAfter(firstIncludedTimestamp),
    );
    return sensorEntries.sublist(firstIndex);
  }

  Duration averageInterval() {
    return Duration(seconds: _intervalStats.average.toInt());
  }

  Duration stdInterval() {
    return Duration(seconds: _intervalStats.standardDeviation.toInt());
  }

  @override
  String toString() {
    return "#Entries: ${sensorEntries.length}, avg interval: ${averageInterval()}, std interval: ${stdInterval()}";
  }
}
