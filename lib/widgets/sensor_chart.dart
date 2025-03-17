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
    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(_formatDate(value)),
                reservedSize: 70,
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          minX: sensorEntries.first.timestamp.millisecondsSinceEpoch.toDouble(),
          maxX: sensorEntries.last.timestamp.millisecondsSinceEpoch.toDouble(),
          minY: 20,
          maxY: 25,
          lineBarsData: [
            LineChartBarData(
              dotData: FlDotData(show: false),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
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
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Theme.of(context).cardColor,
              tooltipBorder: BorderSide(color: Theme.of(context).dividerColor),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(
                    spot.x.toInt(),
                  );
                  final formattedDate = DateFormat(
                    'yyyy-MM-dd',
                  ).format(dateTime);
                  final formattedTime = DateFormat.Hm().format(dateTime);
                  return LineTooltipItem(
                    'Date: $formattedDate\nTime $formattedTime\nTemp: ${spot.y.toStringAsFixed(2)}',
                    Theme.of(context).textTheme.labelMedium!,
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
