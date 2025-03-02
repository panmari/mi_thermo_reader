import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../utils/sensor_entry.dart';

class SensorChart extends StatelessWidget {

  final List<SensorEntry> sensorEntries;

  const SensorChart({super.key, required this.sensorEntries});

  @override
  Widget build(BuildContext context) {
                   return SfCartesianChart(
                        primaryXAxis: DateTimeAxis(),
                        series: <CartesianSeries>[
                            // Renders line chart
                            LineSeries<SensorEntry, DateTime>(
                                dataSource: sensorEntries,
                                xValueMapper: (SensorEntry e, _) => e.timestamp,
                                yValueMapper: (SensorEntry e, _) => e.temperature,
                            )
                        ]
                    );
  }
  
}