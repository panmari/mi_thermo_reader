import 'dart:typed_data';

class SensorEntry {
  final int index;
  final int timestamp;
  final int temperature;
  final int humidity;
  final int voltageBattery;

  @override
  String toString() {
    return 'Index: $index, t: $timestamp, temp: $temperature, h: $humidity, v: $voltageBattery';
  }

  static SensorEntry parse(ByteData data) {
    return SensorEntry(
            index: data.getUint16(1, Endian.little),
            timestamp: data.getUint32(3, Endian.little),
            temperature: data.getInt16(7, Endian.little),
            humidity: data.getUint16(9, Endian.little),
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
