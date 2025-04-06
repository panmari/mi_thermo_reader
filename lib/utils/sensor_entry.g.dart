// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_entry.dart';

// **************************************************************************
// ProtoMapperGenerator
// **************************************************************************

class $SensorEntryProtoMapper
    implements ProtoMapper<SensorEntry, GSensorEntry> {
  const $SensorEntryProtoMapper();

  @override
  SensorEntry fromProto(GSensorEntry proto) => _$SensorEntryFromProto(proto);

  @override
  GSensorEntry toProto(SensorEntry entity) => _$SensorEntryToProto(entity);

  GSensorEntry toFieldsOfProto(SensorEntry entity) =>
      _$SensorEntryToProto(entity);

  SensorEntry fromJson(String json) =>
      _$SensorEntryFromProto(GSensorEntry.fromJson(json));
  String toJson(SensorEntry entity) =>
      _$SensorEntryToProto(entity).writeToJson();

  String toBase64Proto(SensorEntry entity) =>
      base64Encode(utf8.encode(entity.toProto().writeToJson()));

  SensorEntry fromBase64Proto(String base64Proto) =>
      GSensorEntry.fromJson(
        utf8.decode(base64Decode(base64Proto)),
      ).toSensorEntry();
}

GSensorEntry _$SensorEntryToProto(SensorEntry instance) {
  var proto = GSensorEntry();

  proto.index = instance.index;
  proto.timestamp = Int64(instance.timestamp.microsecondsSinceEpoch);
  proto.temperature = instance.temperature;
  proto.humidity = instance.humidity;
  proto.voltageBattery = instance.voltageBattery;

  return proto;
}

SensorEntry _$SensorEntryFromProto(GSensorEntry proto) {
  return SensorEntry(
    index: proto.index,
    timestamp: DateTime.fromMicrosecondsSinceEpoch(proto.timestamp.toInt()),
    temperature: proto.temperature,
    humidity: proto.humidity,
    voltageBattery: proto.voltageBattery,
  );
}

extension $SensorEntryProtoExtension on SensorEntry {
  GSensorEntry toProto() => _$SensorEntryToProto(this);
  String toJson() => _$SensorEntryToProto(this).writeToJson();

  static SensorEntry fromProto(GSensorEntry proto) =>
      _$SensorEntryFromProto(proto);
  static SensorEntry fromJson(String json) =>
      _$SensorEntryFromProto(GSensorEntry.fromJson(json));
}

extension $GSensorEntryProtoExtension on GSensorEntry {
  SensorEntry toSensorEntry() => _$SensorEntryFromProto(this);
}
