import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';

class SensorChart extends StatelessWidget {
  final List<SensorEntry> sensorEntries;

  const SensorChart({super.key, required this.sensorEntries});

  String _formatDate(double value) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateFormat('MMM d').format(dateTime); // Format as "Month Day"
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.7,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget:
                      (value, meta) => Text(
                        _formatDate(value),
                        style: const TextStyle(fontSize: 10),
                      ),
                  // reservedSize: 22,
                  // interval:
                  //     _chartData.length > 1
                  //         ? (_chartData.last.x - _chartData.first.x) /
                  //             (_chartData.length - 1)
                  //         : 1, // Ensure all labels show
                ),
              ),
            ),
            minX:
                sensorEntries.first.timestamp.millisecondsSinceEpoch.toDouble(),
            maxX:
                sensorEntries.last.timestamp.millisecondsSinceEpoch.toDouble(),
            minY: 20,
            maxY: 25,
            lineBarsData: [
              LineChartBarData(
                spots:
                    sensorEntries
                        .map(
                          (s) => FlSpot(
                            s.timestamp.millisecondsSinceEpoch.toDouble(),
                            s.temperature,
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
