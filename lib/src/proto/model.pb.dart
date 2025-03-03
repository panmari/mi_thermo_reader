//
//  Generated code. Do not modify.
//  source: model.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class GSensorEntry extends $pb.GeneratedMessage {
  factory GSensorEntry({
    $core.int? index,
    $fixnum.Int64? timestamp,
    $core.double? temperature,
    $core.double? humidity,
    $core.int? voltageBattery,
  }) {
    final $result = create();
    if (index != null) {
      $result.index = index;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (temperature != null) {
      $result.temperature = temperature;
    }
    if (humidity != null) {
      $result.humidity = humidity;
    }
    if (voltageBattery != null) {
      $result.voltageBattery = voltageBattery;
    }
    return $result;
  }
  GSensorEntry._() : super();
  factory GSensorEntry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GSensorEntry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GSensorEntry', createEmptyInstance: create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'index', $pb.PbFieldType.O3)
    ..aInt64(3, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'temperature', $pb.PbFieldType.OD)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'humidity', $pb.PbFieldType.OD)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'voltageBattery', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GSensorEntry clone() => GSensorEntry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GSensorEntry copyWith(void Function(GSensorEntry) updates) => super.copyWith((message) => updates(message as GSensorEntry)) as GSensorEntry;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GSensorEntry create() => GSensorEntry._();
  GSensorEntry createEmptyInstance() => create();
  static $pb.PbList<GSensorEntry> createRepeated() => $pb.PbList<GSensorEntry>();
  @$core.pragma('dart2js:noInline')
  static GSensorEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GSensorEntry>(create);
  static GSensorEntry? _defaultInstance;

  @$pb.TagNumber(2)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(2)
  set index($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(2)
  void clearIndex() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(3)
  void clearTimestamp() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get temperature => $_getN(2);
  @$pb.TagNumber(4)
  set temperature($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(4)
  $core.bool hasTemperature() => $_has(2);
  @$pb.TagNumber(4)
  void clearTemperature() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get humidity => $_getN(3);
  @$pb.TagNumber(5)
  set humidity($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(5)
  $core.bool hasHumidity() => $_has(3);
  @$pb.TagNumber(5)
  void clearHumidity() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get voltageBattery => $_getIZ(4);
  @$pb.TagNumber(6)
  set voltageBattery($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(6)
  $core.bool hasVoltageBattery() => $_has(4);
  @$pb.TagNumber(6)
  void clearVoltageBattery() => clearField(6);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
