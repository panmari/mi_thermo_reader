import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';

class SensorChart extends StatelessWidget {
  final List<SensorEntry> sensorEntries;

  const SensorChart({super.key, required this.sensorEntries});

  String _formatDate(Duration timeRange, double value) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (timeRange > Duration(days: 1)) {
      return DateFormat('MMM d').format(dateTime); // Format as "Month Day"
    }
    return DateFormat.Hm().format(dateTime);
  }

  Duration _verticalInterval(Duration timeRange) {
    if (timeRange > Duration(days: 6)) {
      return Duration(hours: 48);
    }
    if (timeRange > Duration(days: 1)) {
      return Duration(hours: 6);
    }
    return Duration(hours: 3);
  }

  double _temperatureInterval() {
    final minTemp = sensorEntries
        .map((e) => e.temperature)
        .reduce((currentMin, e) => currentMin < e ? currentMin : e);
    final maxTemp = sensorEntries
        .map((e) => e.temperature)
        .reduce((currentMax, e) => currentMax > e ? currentMax : e);
    final tempRange = maxTemp - minTemp;

    if (tempRange > 5) {
      return 2;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final timeRange = sensorEntries.last.timestamp.difference(
      sensorEntries.first.timestamp,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final reservedSizeHorizontalAxis = 70;
        final numHorizontalLabels =
            constraints.maxWidth / reservedSizeHorizontalAxis;
        return AspectRatio(
          aspectRatio: 2,
          child: LineChart(
            LineChartData(
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              gridData: FlGridData(
                show: true,
                verticalInterval:
                    _verticalInterval(timeRange).inMilliseconds.toDouble(),
                horizontalInterval: _temperatureInterval(),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget:
                        (value, meta) => Text(_formatDate(timeRange, value)),
                    reservedSize: 70,
                    interval: timeRange.inMilliseconds / numHorizontalLabels,
                    minIncluded: false,
                    maxIncluded: false,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _temperatureInterval(),
                    minIncluded: false,
                    maxIncluded: false,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
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
                  tooltipBorder: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
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
                        'Date: $formattedDate\nTime $formattedTime\nTemp: ${spot.y.toStringAsFixed(2)}° C',
                        Theme.of(context).textTheme.labelMedium!,
                        textAlign: TextAlign.left,
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
