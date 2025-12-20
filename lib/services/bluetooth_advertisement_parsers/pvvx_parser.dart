import 'dart:typed_data';

class PvvxData {
  final String macAddress;
  final double temperature;
  final double humidity;
  final double voltage;
  final int batteryLevel;
  final int counter;
  final int flags;

  const PvvxData({
    required this.macAddress,
    required this.temperature,
    required this.humidity,
    required this.voltage,
    required this.batteryLevel,
    required this.counter,
    required this.flags,
  });
}

/// Parser for PVVX Custom Format (Telink Mi Flasher).
///
/// Based on logic found in TelinkMiFlasher.html for Service UUID 0x181A.
/// This format is positional (fixed offsets), not Tag-Length-Value like BTHome.
/// See https://github.com/pvvx/ATC_MiThermometer?tab=readme-ov-file#custom-format-all-data-little-endian
class PvvxParser {
  /// Parses the Service Data buffer for UUID 0x181A.
  static PvvxData parse(List<int> serviceData) {
    // The JS code check: if(b.byteLength >= 15)
    if (serviceData.isEmpty || serviceData.length < 15) {
      throw ArgumentError(
        'Invalid length for PVVX advertisement data: '
        '${serviceData.length}. Expected at least 15 bytes.',
      );
    }

    final byteData = ByteData.view(Uint8List.fromList(serviceData).buffer);

    // --- MAC Address (Bytes 0-5) ---
    // Source JS: hex(buf[5],2)+hex(buf[4],2)+hex(buf[3],2)+hex(buf[2],2)+hex(buf[1],2)+hex(buf[0],2)
    // Stored in Little Endian.
    final macBytes = serviceData.sublist(0, 6).reversed.toList();
    final macString = macBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');

    // --- Temperature (Bytes 6-7) ---
    // Source JS: let temp = b.getInt16(6, true) / 100.0;
    // Unit: Celsius
    final tempRaw = byteData.getInt16(6, Endian.little);
    final temperature = tempRaw / 100.0;

    // --- Humidity (Bytes 8-9) ---
    // Source JS: let humi = b.getInt16(8, true) / 100.0;
    // Unit: Percent (%)
    final humiRaw = byteData.getInt16(8, Endian.little);
    final humidity = humiRaw / 100.0;

    // --- Voltage (Bytes 10-11) ---
    // Source JS: let vbat = b.getUint16(10, true);
    // Source Unit: mV. Converted to V to match BTHome parser style.
    final voltageMv = byteData.getUint16(10, Endian.little);
    final voltage = voltageMv / 1000.0;

    // --- Battery Level (Byte 12) ---
    // Source JS: let bat = b.getUint8(12);
    // Unit: Percent (%)
    final batteryLevel = byteData.getUint8(12);

    // --- Message Counter (Byte 13) ---
    // Source JS: let cnt = b.getUint8(13);
    final counter = byteData.getUint8(13);

    // --- Flags (Byte 14) ---
    // Source JS: let flg = b.getUint8(14);
    final flags = byteData.getUint8(14);

    return PvvxData(
      macAddress: macString,
      temperature: temperature,
      humidity: humidity,
      voltage: voltage,
      batteryLevel: batteryLevel,
      counter: counter,
      flags: flags,
    );
  }
}
