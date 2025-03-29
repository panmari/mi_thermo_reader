//
//  Generated code. Do not modify.
//  source: model.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use gKnownDeviceDescriptor instead')
const GKnownDevice$json = {
  '1': 'GKnownDevice',
  '2': [
    {'1': 'adv_name', '3': 2, '4': 1, '5': 9, '10': 'advName'},
    {'1': 'platform_name', '3': 3, '4': 1, '5': 9, '10': 'platformName'},
    {'1': 'remote_id', '3': 4, '4': 1, '5': 9, '10': 'remoteId'},
  ],
};

/// Descriptor for `GKnownDevice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gKnownDeviceDescriptor = $convert.base64Decode(
    'CgxHS25vd25EZXZpY2USGQoIYWR2X25hbWUYAiABKAlSB2Fkdk5hbWUSIwoNcGxhdGZvcm1fbm'
    'FtZRgDIAEoCVIMcGxhdGZvcm1OYW1lEhsKCXJlbW90ZV9pZBgEIAEoCVIIcmVtb3RlSWQ=');

@$core.Deprecated('Use gSensorEntryDescriptor instead')
const GSensorEntry$json = {
  '1': 'GSensorEntry',
  '2': [
    {'1': 'index', '3': 2, '4': 1, '5': 5, '10': 'index'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'temperature', '3': 4, '4': 1, '5': 1, '10': 'temperature'},
    {'1': 'humidity', '3': 5, '4': 1, '5': 1, '10': 'humidity'},
    {'1': 'voltage_battery', '3': 6, '4': 1, '5': 5, '10': 'voltageBattery'},
  ],
};

/// Descriptor for `GSensorEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gSensorEntryDescriptor = $convert.base64Decode(
    'CgxHU2Vuc29yRW50cnkSFAoFaW5kZXgYAiABKAVSBWluZGV4EhwKCXRpbWVzdGFtcBgDIAEoA1'
    'IJdGltZXN0YW1wEiAKC3RlbXBlcmF0dXJlGAQgASgBUgt0ZW1wZXJhdHVyZRIaCghodW1pZGl0'
    'eRgFIAEoAVIIaHVtaWRpdHkSJwoPdm9sdGFnZV9iYXR0ZXJ5GAYgASgFUg52b2x0YWdlQmF0dG'
    'VyeQ==');

@$core.Deprecated('Use gSensorHistoryDescriptor instead')
const GSensorHistory$json = {
  '1': 'GSensorHistory',
  '2': [
    {
      '1': 'sensor_entries',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.GSensorEntry',
      '10': 'sensorEntries'
    },
  ],
};

/// Descriptor for `GSensorHistory`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gSensorHistoryDescriptor = $convert.base64Decode(
    'Cg5HU2Vuc29ySGlzdG9yeRI0Cg5zZW5zb3JfZW50cmllcxgCIAMoCzINLkdTZW5zb3JFbnRyeV'
    'INc2Vuc29yRW50cmllcw==');
