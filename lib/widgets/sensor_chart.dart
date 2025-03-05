import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../utils/sensor_entry.dart';

class SensorChart extends StatelessWidget {
  final List<SensorEntry> sensorEntries;

  const SensorChart({super.key, required this.sensorEntries});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: 'Temperature'),
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: DateTimeAxis(),
      primaryYAxis: const NumericAxis(
        minimum: 20, // TODO(panmari): Compute.
      ),
      series: <CartesianSeries>[
        // Renders line chart
        LineSeries<SensorEntry, DateTime>(
          dataSource: sensorEntries,
          xValueMapper: (SensorEntry e, _) => e.timestamp,
          yValueMapper: (SensorEntry e, _) => e.temperature,
        ),
      ],
    );
  }
}
