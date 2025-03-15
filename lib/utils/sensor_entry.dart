import 'dart:typed_data';

import 'package:mi_thermo_reader/src/proto/model.pb.dart';
import 'package:proto_annotations/proto_annotations.dart';

part 'sensor_entry.g.dart';

// After changing this file, also regenerate the proto definition. See
// https://pub.dev/packages/proto_generator#getting-started.
@proto
class SensorEntry {
  @ProtoField(2)
  final int index;
  @ProtoField(3)
  final DateTime timestamp;
  // In degrees.
  @ProtoField(4)
  final double temperature;
  @ProtoField(5)
  final double humidity;
  @ProtoField(6)
  final int voltageBattery;

  @override
  String toString() {
    return 'Index: $index, t: $timestamp, temp: $temperature, h: $humidity, v: $voltageBattery';
  }

  static SensorEntry parse(ByteData data) {
    return SensorEntry(
      index: data.getUint16(1, Endian.little),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        data.getUint32(3, Endian.little) * 1000,
      ),
      temperature: data.getInt16(7, Endian.little) / 100,
      humidity: data.getUint16(9, Endian.little) / 100,
      voltageBattery: data.getUint16(11, Endian.little),
    );
  }

  SensorEntry({
    required this.index,
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.voltageBattery,
  });
}

@proto
class SensorHistory {
  @ProtoField(2)
  final List<SensorEntry> sensorEntries;

  SensorHistory({required this.sensorEntries});

  static SensorHistory from(String base64ProtoString) {
    final buffer = base64Decode(base64ProtoString);
    return GSensorHistory.fromBuffer(buffer).toSensorHistory();
  }

  String toBase64ProtoString() {
    return base64Encode(toProto().writeToBuffer());
  }
}
