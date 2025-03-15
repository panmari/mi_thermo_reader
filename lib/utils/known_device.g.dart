// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'known_device.dart';

// **************************************************************************
// ProtoMapperGenerator
// **************************************************************************

class $KnownDeviceProtoMapper
    implements ProtoMapper<KnownDevice, GKnownDevice> {
  const $KnownDeviceProtoMapper();

  @override
  KnownDevice fromProto(GKnownDevice proto) => _$KnownDeviceFromProto(proto);

  @override
  GKnownDevice toProto(KnownDevice entity) => _$KnownDeviceToProto(entity);

  GKnownDevice toFieldsOfProto(KnownDevice entity) =>
      _$KnownDeviceToProto(entity);

  KnownDevice fromJson(String json) =>
      _$KnownDeviceFromProto(GKnownDevice.fromJson(json));
  String toJson(KnownDevice entity) =>
      _$KnownDeviceToProto(entity).writeToJson();

  String toBase64Proto(KnownDevice entity) =>
      base64Encode(utf8.encode(entity.toProto().writeToJson()));

  KnownDevice fromBase64Proto(String base64Proto) =>
      GKnownDevice.fromJson(utf8.decode(base64Decode(base64Proto)))
          .toKnownDevice();
}

GKnownDevice _$KnownDeviceToProto(KnownDevice instance) {
  var proto = GKnownDevice();

  proto.advName = instance.advName;
  proto.platformName = instance.platformName;
  proto.remoteId = instance.remoteId;

  return proto;
}

KnownDevice _$KnownDeviceFromProto(GKnownDevice proto) {
  return KnownDevice(
    advName: proto.advName,
    platformName: proto.platformName,
    remoteId: proto.remoteId,
  );
}

extension $KnownDeviceProtoExtension on KnownDevice {
  GKnownDevice toProto() => _$KnownDeviceToProto(this);
  String toJson() => _$KnownDeviceToProto(this).writeToJson();

  static KnownDevice fromProto(GKnownDevice proto) =>
      _$KnownDeviceFromProto(proto);
  static KnownDevice fromJson(String json) =>
      _$KnownDeviceFromProto(GKnownDevice.fromJson(json));
}

extension $GKnownDeviceProtoExtension on GKnownDevice {
  KnownDevice toKnownDevice() => _$KnownDeviceFromProto(this);
}
