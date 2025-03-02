import 'dart:typed_data';

class SensorEntry {
  final int index;
  final DateTime timestamp;
  // In degrees.
  final double temperature;
  final double humidity;
  final int voltageBattery;

  @override
  String toString() {
    return 'Index: $index, t: $timestamp, temp: $temperature, h: $humidity, v: $voltageBattery';
  }

  static SensorEntry parse(ByteData data) {
    return SensorEntry(
            index: data.getUint16(1, Endian.little),
            timestamp: DateTime.fromMillisecondsSinceEpoch(data.getUint32(3, Endian.little) * 1000),
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
