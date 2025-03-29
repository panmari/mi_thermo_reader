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

class $SensorHistoryProtoMapper
    implements ProtoMapper<SensorHistory, GSensorHistory> {
  const $SensorHistoryProtoMapper();

  @override
  SensorHistory fromProto(GSensorHistory proto) =>
      _$SensorHistoryFromProto(proto);

  @override
  GSensorHistory toProto(SensorHistory entity) =>
      _$SensorHistoryToProto(entity);

  GSensorHistory toFieldsOfProto(SensorHistory entity) =>
      _$SensorHistoryToProto(entity);

  SensorHistory fromJson(String json) =>
      _$SensorHistoryFromProto(GSensorHistory.fromJson(json));
  String toJson(SensorHistory entity) =>
      _$SensorHistoryToProto(entity).writeToJson();

  String toBase64Proto(SensorHistory entity) =>
      base64Encode(utf8.encode(entity.toProto().writeToJson()));

  SensorHistory fromBase64Proto(String base64Proto) =>
      GSensorHistory.fromJson(
        utf8.decode(base64Decode(base64Proto)),
      ).toSensorHistory();
}

GSensorHistory _$SensorHistoryToProto(SensorHistory instance) {
  var proto = GSensorHistory();

  proto.sensorEntries.addAll(
    instance.sensorEntries.map(
      (e) => const $SensorEntryProtoMapper().toProto(e),
    ),
  );

  return proto;
}

SensorHistory _$SensorHistoryFromProto(GSensorHistory proto) {
  return SensorHistory(
    sensorEntries: List<SensorEntry>.unmodifiable(
      proto.sensorEntries.map(
        (e) => const $SensorEntryProtoMapper().fromProto(e),
      ),
    ),
  );
}

extension $SensorHistoryProtoExtension on SensorHistory {
  GSensorHistory toProto() => _$SensorHistoryToProto(this);
  String toJson() => _$SensorHistoryToProto(this).writeToJson();

  static SensorHistory fromProto(GSensorHistory proto) =>
      _$SensorHistoryFromProto(proto);
  static SensorHistory fromJson(String json) =>
      _$SensorHistoryFromProto(GSensorHistory.fromJson(json));
}

extension $GSensorHistoryProtoExtension on GSensorHistory {
  SensorHistory toSensorHistory() => _$SensorHistoryFromProto(this);
}
