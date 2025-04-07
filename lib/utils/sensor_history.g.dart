// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_history.dart';

// **************************************************************************
// ProtoMapperGenerator
// **************************************************************************

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
