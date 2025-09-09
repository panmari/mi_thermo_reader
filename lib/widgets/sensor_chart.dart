import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'dart:math'; // Import for min/max

class SensorChart extends StatelessWidget {
  final List<SensorEntry> sensorEntries;

  final Color tempColor = Colors.orange;
  final Color humidityColor = Colors.blue;

  const SensorChart({super.key, required this.sensorEntries});

  // Helper to format dates on the X-axis based on the total time range.
  // For short time ranges, a more detailed format is used.
  String _formatDate(Duration timeRange, double value) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (timeRange.inDays > 2) {
      return DateFormat('MMM d').format(dateTime); // e.g., "Apr 9"
    }
    return DateFormat('HH:mm').format(dateTime); // e.g., "11:41"
  }

  // Calculate a reasonable interval for vertical grid lines (time axis)
  Duration _calculateTimeGridIntervalDuration(Duration timeRange) {
    // Aim for roughly 5-10 grid lines
    if (timeRange.inDays > 30) {
      return Duration(days: 7);
    }
    if (timeRange.inDays > 6) {
      return Duration(days: 2);
    }
    if (timeRange.inDays > 1) {
      return Duration(days: 1);
    }
    // Works best for aligning with labels.
    return Duration(hours: 5);
  }

  // Calculate a reasonable interval for horizontal grid lines (based on primary axis - Temperature)
  double _calculateTempGridInterval(double tempRange) {
    if (tempRange <= 0) return 1; // Avoid issues with zero range
    if (tempRange > 10) return 2;
    if (tempRange > 3) return 1;
    return 0.5; // Finer grid for small ranges
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty data case
    if (sensorEntries.isEmpty) {
      return const AspectRatio(
        aspectRatio: 2,
        child: Center(child: Text('No sensor data available.')),
      );
    }

    Size size = MediaQuery.of(context).size;
    // Landscape, make sure the whole chart is visible on a single screen.
    if (size.width > size.height) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width,
          maxHeight: size.height * 0.6,
        ),
        child: _buildChart(context),
      );
    }
    // Portrait, use the full width and keep aspect ratio fixed.
    return AspectRatio(
      aspectRatio: 2, // Maintain aspect ratio
      child: _buildChart(context),
    );
  }

  Widget _buildChart(BuildContext context) {
    // --- Calculate Ranges ---
    // Time range (X-axis)
    final minTimestamp =
        sensorEntries.first.timestamp.millisecondsSinceEpoch.toDouble();
    // TODO(panmari): Align minX and maxX to full days if the time range is appropriate.
    // Ensure minX is rounded to the previous full hour
    final minX =
        sensorEntries.first.timestamp
            .copyWith(minute: 0, second: 0, millisecond: 0, microsecond: 0)
            .millisecondsSinceEpoch
            .toDouble();
    final maxTimestamp =
        sensorEntries.last.timestamp.millisecondsSinceEpoch.toDouble();
    // Ensure maxX is rounded to the next full hour
    final maxX =
        sensorEntries.last.timestamp
            .add(const Duration(minutes: 59, seconds: 59))
            .copyWith(minute: 0, second: 0, millisecond: 0, microsecond: 0)
            .millisecondsSinceEpoch
            .toDouble();
    final timeRange = Duration(
      milliseconds: (maxTimestamp - minTimestamp).toInt(),
    );

    // Temperature range (Y-axis Left - Primary)
    final minTemp = sensorEntries.map((e) => e.temperature).reduce(min);
    final maxTemp = sensorEntries.map((e) => e.temperature).reduce(max);
    final double tempPadding = (maxTemp - minTemp) * 0.15; // Add 15% padding
    final double finalMinY =
        (minTemp - tempPadding)
            .floorToDouble(); // Use temperature for internal Y scale
    final double finalMaxY = (maxTemp + tempPadding).ceilToDouble();
    final double primaryYRange = max(
      1,
      finalMaxY - finalMinY,
    ); // Ensure range is at least 1

    // Humidity range (Y-axis Right - Secondary) - needed for normalization and labels
    final minHumidity = sensorEntries.map((e) => e.humidity).reduce(min);
    final maxHumidity = sensorEntries.map((e) => e.humidity).reduce(max);
    // Ensure humidity range doesn't exceed 0-100 bounds for padding calculation
    final double humidityPadding = (maxHumidity - minHumidity) * 0.15;
    final double finalMinHumidity = max(
      0,
      minHumidity - humidityPadding,
    ); // Clamp min at 0%
    final double finalMaxHumidity = min(
      100,
      maxHumidity + humidityPadding,
    ); // Clamp max at 100%
    final double secondaryYRange = max(
      1,
      finalMaxHumidity - finalMinHumidity,
    ); // Ensure range is at least 1

    // --- Normalize Humidity Data ---
    final List<FlSpot> normalizedHumiditySpots =
        sensorEntries.map((s) {
          final double originalY = s.humidity;
          // Normalize humidity value to fit within the finalMinY/finalMaxY (temperature) range
          final double normalizedY =
              finalMinY +
              ((originalY - finalMinHumidity) / secondaryYRange) *
                  primaryYRange;
          return FlSpot(
            s.timestamp.millisecondsSinceEpoch.toDouble(),
            normalizedY,
          );
        }).toList();

    // --- Prepare Temperature Spots ---
    final List<FlSpot> temperatureSpots =
        sensorEntries
            .map(
              (s) => FlSpot(
                s.timestamp.millisecondsSinceEpoch.toDouble(),
                s.temperature,
              ),
            )
            .toList();

    final int numHorizontalLabels = 5;
    final double bottomTitleInterval = (maxX - minX) / numHorizontalLabels;

    return LineChart(
      LineChartData(
        // --- General Appearance ---
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1.5,
            ),
            left: BorderSide(color: Theme.of(context).dividerColor, width: 1.5),
            right: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1.5,
            ), // Show right border too
            top: BorderSide.none,
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval:
              _calculateTimeGridIntervalDuration(
                timeRange,
              ).inMilliseconds.toDouble(),
          drawHorizontalLine: true,
          horizontalInterval: _calculateTempGridInterval(
            maxTemp - minTemp,
          ), // Base grid on temperature scale
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Theme.of(context).dividerColor.withAlpha(50),
                strokeWidth: 1,
              ),
          getDrawingVerticalLine:
              (value) => FlLine(
                color: Theme.of(context).dividerColor.withAlpha(50),
                strokeWidth: 1,
              ),
        ),

        // --- Axis Range Definitions ---
        minX: minX,
        maxX: maxX,
        minY: finalMinY, // Based on temperature range
        maxY: finalMaxY, // Based on temperature range
        // --- Line Data ---
        lineBarsData: [
          // Temperature Line (Left Axis)
          LineChartBarData(
            spots: temperatureSpots,
            color: tempColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false), // Hide dots on line
          ),
          // Humidity Line (Right Axis - uses normalized data)
          LineChartBarData(
            spots: normalizedHumiditySpots,
            color: humidityColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false), // Hide dots on line
          ),
        ],

        // --- Axis Titles (Labels) ---
        titlesData: FlTitlesData(
          show: true,

          // Bottom (X - Time Axis)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              minIncluded: false,
              maxIncluded: false,
              showTitles: true,
              reservedSize: 35, // Space for labels below chart
              interval: bottomTitleInterval,
              getTitlesWidget: (value, TitleMeta meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _formatDate(timeRange, value),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),

          // Left (Y - Temperature Axis)
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              'Temp (°C)',
              style: TextStyle(color: tempColor),
            ),
            axisNameSize: 24, // Space for axis title
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28, // Space for labels + padding
              // Use the same interval as the horizontal grid for consistency
              interval: max(1, (primaryYRange / 5).roundToDouble()),
              getTitlesWidget: (value, meta) {
                // Only show labels within the calculated Y range
                if (value < finalMinY || value > finalMaxY) {
                  return Container();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    meta.formattedValue,
                    style: TextStyle(color: tempColor),
                  ),
                );
              },
            ),
          ),

          // Right (Y - Humidity Axis)
          rightTitles: AxisTitles(
            axisNameWidget: Text(
              'Humidity (%)',
              style: TextStyle(color: humidityColor),
            ),
            axisNameSize: 24,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28, // Match left side
              // Use an interval based on primaryY, aiming for ~5 labels
              interval: max(1, (primaryYRange / 5).roundToDouble()),
              getTitlesWidget: (value, meta) {
                // 'value' here is on the TEMPERATURE scale (finalMinY to finalMaxY)
                // We need to reverse-normalize it to get the humidity value

                // Only calculate for values within the displayed range
                if (value < finalMinY || value > finalMaxY) {
                  return Container();
                }

                // Reverse normalization:
                final double originalHumidity =
                    finalMinHumidity +
                    ((value - finalMinY) / primaryYRange) * secondaryYRange;

                // Don't show labels outside the actual humidity range
                if (originalHumidity < finalMinHumidity ||
                    originalHumidity > finalMaxHumidity) {
                  // This can happen due to range padding or interval alignment
                  // return Container(); // Option 1: Hide them
                  // Option 2: Clamp them (might look slightly off if intervals are large)
                  if (originalHumidity < finalMinHumidity) {
                    return Container(); // Hide below min
                  }
                  if (originalHumidity > finalMaxHumidity) {
                    return Container(); // Hide above max
                  }
                }

                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    originalHumidity.toStringAsFixed(0),
                    style: TextStyle(color: humidityColor),
                  ),
                );
              },
            ),
          ),

          // Hide Top Titles
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),

        // --- Tooltips ---
        lineTouchData: LineTouchData(
          enabled: true,
          getTouchedSpotIndicator: (barData, spotIndexes) {
            // Customize touch indicator appearance
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  strokeWidth: 2,
                ),
                FlDotData(
                  getDotPainter:
                      (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 6,
                        color: barData.color ?? Colors.black,
                        strokeWidth: 2,
                        strokeColor: Theme.of(context).colorScheme.surface,
                      ),
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            tooltipBorder: BorderSide(color: Theme.of(context).dividerColor),
            getTooltipItems: (touchedSpots) {
              final textStyle = TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                touchedSpots.first.x.toInt(),
              );
              final String formattedDate = DateFormat(
                'yyyy-MM-dd HH:mm:ss',
              ).format(dateTime);
              // Make sure temperature always appears first.
              touchedSpots.sort((a, b) => a.barIndex.compareTo(b.barIndex));
              final items = touchedSpots.map((LineBarSpot touchedSpot) {
                if (touchedSpot.barIndex == 0) {
                  return 'Temperature: ${touchedSpot.y.toStringAsFixed(1)}°C\n';
                } else {
                  // The touchedSpot.y is NORMALIZED humidity. Reverse-normalize it.
                  final double originalHumidity =
                      finalMinHumidity +
                      ((touchedSpot.y - finalMinY) / primaryYRange) *
                          secondaryYRange;
                  // Another approach that doesn't rely on on reverse-normalizing
                  // would be to look up the original entry using dateTime.
                  return 'Humidity: ${originalHumidity.toStringAsFixed(1)}%';
                }
              });
              return [
                LineTooltipItem(
                  '$formattedDate\n',
                  textStyle.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 10,
                  ),
                  children:
                      items
                          .map((t) => TextSpan(text: t, style: textStyle))
                          .toList(),
                  textAlign: TextAlign.left,
                ),
                null, // getTooltipItems expects output to be same length as input.
              ];
            },
          ),
        ),
      ),
    );
  }
}
