import 'package:mi_thermo_reader/src/proto/model.pb.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:proto_annotations/proto_annotations.dart';
import 'package:stats/stats.dart';

part 'sensor_history.g.dart';

@proto
class SensorHistory {
  @ProtoField(2)
  final List<SensorEntry> sensorEntries;
  Stats? _intervalStats;

  SensorHistory({required this.sensorEntries}) {
    if (sensorEntries.length < 2) {
      // Can't define stats, return early.
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

  static SensorHistory createUpdated(
    SensorHistory? old,
    List<SensorEntry> newEntries,
  ) {
    final List<SensorEntry> updated = List.from(old?.sensorEntries ?? []);
    updated.addAll(newEntries);
    // They are sent in reverse chronological order, and might be received out of order.
    // Plus there might be retries. Be very defensive about keeping each value only once.
    updated.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final alreadyPresent = <DateTime>{}; // This is a set.
    updated.retainWhere((e) => alreadyPresent.add(e.timestamp));
    return SensorHistory(sensorEntries: updated);
  }

  // Returns a new SensorHistory without entries in the range [start, end].
  SensorHistory copyWithEntriesFiltered(DateTime start, DateTime end) {
    final updated =
        sensorEntries.where((entry) {
          final ts = entry.timestamp;
          return ts.isBefore(start) || ts.isAfter(end);
        }).toList();
    return SensorHistory(sensorEntries: updated);
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
    if (_intervalStats == null) {
      return Duration.zero;
    }
    return Duration(seconds: _intervalStats!.mean.toInt());
  }

  Duration stdInterval() {
    if (_intervalStats == null) {
      return Duration.zero;
    }

    return Duration(
      seconds: _intervalStats!.populationValues.standardDeviation.toInt(),
    );
  }

  @override
  String toString() {
    return "#Entries: ${sensorEntries.length}, avg interval: ${averageInterval()}, std interval: ${stdInterval()}";
  }

  int missingEntriesSince(DateTime dateTime) {
    if (sensorEntries.length < 2 || _intervalStats == null) {
      // Can't compute interval, return early with a large value
      return 5000;
    }
    final Duration diff = dateTime.difference(sensorEntries.last.timestamp);
    if (diff < Duration.zero) {
      return 0;
    }
    return diff.inSeconds.toInt() ~/ _intervalStats!.mean.toInt();
  }
}
