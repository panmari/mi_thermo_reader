import 'dart:typed_data';

enum ObjectId {
  packedID(0x00),
  battery(0x01),
  temperature(0x02),
  humidity(0x03),
  voltage(0x0c),
  power(0x10);

  final int value;
  const ObjectId(this.value);

  static ObjectId fromValue(int value) {
    return ObjectId.values.firstWhere(
      (element) => element.value == value,
      orElse:
          () =>
              throw UnimplementedError(
                'Unknown ObjectId: 0x${value.toRadixString(16)}',
              ),
    );
  }

  @override
  String toString() {
    return '$name (${value.toRadixString(16)})';
  }
}

// See https://bthome.io/format/.
class BTHomeV2Parser {
  static Map<ObjectId, dynamic> parse(List<int> advertisementData) {
    if (advertisementData.isEmpty) {
      return {};
    }

    int offset = 0;
    final byteData = ByteData.view(
      Uint8List.fromList(advertisementData).buffer,
    );

    final btDeviceInformation = byteData.getUint8(offset++);
    final isEncrypted = (btDeviceInformation & (1 << 0)) != 0;
    final isMacIncluded = (btDeviceInformation & (1 << 1)) != 0;
    final isSleepyDevice = (btDeviceInformation & (1 << 2)) != 0;
    final version = (btDeviceInformation >> 5 & 7);

    if (version != 2) {
      throw ArgumentError('Only BTHome V2 is supported. Got V$version');
    }
    if (isEncrypted) {
      throw UnimplementedError('Encrypted BTHome data is not supported.');
    }
    final result = <ObjectId, dynamic>{};
    while (offset < byteData.lengthInBytes) {
      final id = ObjectId.fromValue(byteData.getUint8(offset++));
      switch (id) {
        case ObjectId.packedID:
          result[id] = byteData.getUint8(offset++);
          break;
        case ObjectId.battery:
          result[id] = byteData.getUint8(offset++);
          break;
        case ObjectId.temperature:
          result[id] = byteData.getInt16(offset, Endian.little) / 100;
          offset += 2;
          break;
        case ObjectId.humidity:
          result[id] = byteData.getUint16(offset, Endian.little) / 100;
          offset += 2;
          break;
        case ObjectId.voltage:
          result[id] = byteData.getUint16(offset, Endian.little) / 1000;
          offset += 2;
          break;
        case ObjectId.power:
          result[id] = byteData.getUint8(offset++) == 1;
          break;
        default:
          throw UnimplementedError('ObjectId not handled: $id');
      }
    }
    return result;
  }
}
