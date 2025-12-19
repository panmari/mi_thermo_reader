// This is a generated file - do not edit.
//
// Generated from model.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class GKnownDevice extends $pb.GeneratedMessage {
  factory GKnownDevice({
    $core.String? advName,
    $core.String? platformName,
    $core.String? remoteId,
  }) {
    final result = create();
    if (advName != null) result.advName = advName;
    if (platformName != null) result.platformName = platformName;
    if (remoteId != null) result.remoteId = remoteId;
    return result;
  }

  GKnownDevice._();

  factory GKnownDevice.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GKnownDevice.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GKnownDevice',
      createEmptyInstance: create)
    ..aOS(2, _omitFieldNames ? '' : 'advName')
    ..aOS(3, _omitFieldNames ? '' : 'platformName')
    ..aOS(4, _omitFieldNames ? '' : 'remoteId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GKnownDevice clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GKnownDevice copyWith(void Function(GKnownDevice) updates) =>
      super.copyWith((message) => updates(message as GKnownDevice))
          as GKnownDevice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GKnownDevice create() => GKnownDevice._();
  @$core.override
  GKnownDevice createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GKnownDevice getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GKnownDevice>(create);
  static GKnownDevice? _defaultInstance;

  @$pb.TagNumber(2)
  $core.String get advName => $_getSZ(0);
  @$pb.TagNumber(2)
  set advName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(2)
  $core.bool hasAdvName() => $_has(0);
  @$pb.TagNumber(2)
  void clearAdvName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get platformName => $_getSZ(1);
  @$pb.TagNumber(3)
  set platformName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(3)
  $core.bool hasPlatformName() => $_has(1);
  @$pb.TagNumber(3)
  void clearPlatformName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get remoteId => $_getSZ(2);
  @$pb.TagNumber(4)
  set remoteId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasRemoteId() => $_has(2);
  @$pb.TagNumber(4)
  void clearRemoteId() => $_clearField(4);
}

class GSensorEntry extends $pb.GeneratedMessage {
  factory GSensorEntry({
    $core.int? index,
    $fixnum.Int64? timestamp,
    $core.double? temperature,
    $core.double? humidity,
    $core.int? voltageBattery,
  }) {
    final result = create();
    if (index != null) result.index = index;
    if (timestamp != null) result.timestamp = timestamp;
    if (temperature != null) result.temperature = temperature;
    if (humidity != null) result.humidity = humidity;
    if (voltageBattery != null) result.voltageBattery = voltageBattery;
    return result;
  }

  GSensorEntry._();

  factory GSensorEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GSensorEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GSensorEntry',
      createEmptyInstance: create)
    ..aI(2, _omitFieldNames ? '' : 'index')
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..aD(4, _omitFieldNames ? '' : 'temperature')
    ..aD(5, _omitFieldNames ? '' : 'humidity')
    ..aI(6, _omitFieldNames ? '' : 'voltageBattery')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GSensorEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GSensorEntry copyWith(void Function(GSensorEntry) updates) =>
      super.copyWith((message) => updates(message as GSensorEntry))
          as GSensorEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GSensorEntry create() => GSensorEntry._();
  @$core.override
  GSensorEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GSensorEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GSensorEntry>(create);
  static GSensorEntry? _defaultInstance;

  @$pb.TagNumber(2)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(2)
  set index($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(2)
  void clearIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get temperature => $_getN(2);
  @$pb.TagNumber(4)
  set temperature($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(4)
  $core.bool hasTemperature() => $_has(2);
  @$pb.TagNumber(4)
  void clearTemperature() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get humidity => $_getN(3);
  @$pb.TagNumber(5)
  set humidity($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(5)
  $core.bool hasHumidity() => $_has(3);
  @$pb.TagNumber(5)
  void clearHumidity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get voltageBattery => $_getIZ(4);
  @$pb.TagNumber(6)
  set voltageBattery($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(6)
  $core.bool hasVoltageBattery() => $_has(4);
  @$pb.TagNumber(6)
  void clearVoltageBattery() => $_clearField(6);
}

class GSensorHistory extends $pb.GeneratedMessage {
  factory GSensorHistory({
    $core.Iterable<GSensorEntry>? sensorEntries,
  }) {
    final result = create();
    if (sensorEntries != null) result.sensorEntries.addAll(sensorEntries);
    return result;
  }

  GSensorHistory._();

  factory GSensorHistory.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GSensorHistory.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GSensorHistory',
      createEmptyInstance: create)
    ..pPM<GSensorEntry>(2, _omitFieldNames ? '' : 'sensorEntries',
        subBuilder: GSensorEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GSensorHistory clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GSensorHistory copyWith(void Function(GSensorHistory) updates) =>
      super.copyWith((message) => updates(message as GSensorHistory))
          as GSensorHistory;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GSensorHistory create() => GSensorHistory._();
  @$core.override
  GSensorHistory createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GSensorHistory getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GSensorHistory>(create);
  static GSensorHistory? _defaultInstance;

  @$pb.TagNumber(2)
  $pb.PbList<GSensorEntry> get sensorEntries => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
