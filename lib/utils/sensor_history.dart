import 'package:mi_thermo_reader/src/proto/model.pb.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:proto_annotations/proto_annotations.dart';

part 'sensor_history.g.dart';

@proto
class SensorHistory {
  @ProtoField(2)
  final List<SensorEntry> sensorEntries;

  SensorHistory({required this.sensorEntries});

  static SensorHistory from(String base64ProtoString) {
    final buffer = base64Decode(base64ProtoString);
    return GSensorHistory.fromBuffer(buffer).toSensorHistory();
  }

  String toBase64ProtoString() {
    return base64Encode(toProto().writeToBuffer());
  }
}
