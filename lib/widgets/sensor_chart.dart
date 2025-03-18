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

  double get _firstTimestampAsMilliseconds =>
      sensorEntries.first.timestamp.millisecondsSinceEpoch.toDouble();
  double get _lastTimestampAsMilliseconds =>
      sensorEntries.last.timestamp.millisecondsSinceEpoch.toDouble();

  @override
  Widget build(BuildContext context) {
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
                verticalInterval: Duration(hours: 24).inMilliseconds.toDouble(),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text(_formatDate(value)),
                    reservedSize: 70,
                    interval:
                        (_lastTimestampAsMilliseconds -
                            _firstTimestampAsMilliseconds) /
                        numHorizontalLabels,
                    minIncluded: false,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              minX: _firstTimestampAsMilliseconds,
              maxX: _lastTimestampAsMilliseconds,
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
