import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:mi_thermo_reader/widgets/sensor_chart.dart';
import 'package:region_settings/region_settings.dart';

void main() {
  testWidgets('SensorChart tooltip formats temperature with temperatureUnit', (
    WidgetTester tester,
  ) async {
    final entries = [
      SensorEntry(
        index: 0,
        timestamp: DateTime(2025, 1, 1, 12, 0),
        temperature: 20.0,
        humidity: 50.0,
        voltageBattery: 3000,
      ),
      SensorEntry(
        index: 1,
        timestamp: DateTime(2025, 1, 1, 13, 0),
        temperature: 21.0,
        humidity: 52.0,
        voltageBattery: 3000,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SensorChart(
            sensorEntries: entries,
            temperatureUnit: TemperatureUnit.fahrenheit,
          ),
        ),
      ),
    );

    final lineChartFinder = find.byType(LineChart);
    expect(lineChartFinder, findsOneWidget);

    final LineChart lineChart = tester.widget<LineChart>(lineChartFinder);
    final tooltipData = lineChart.data.lineTouchData.touchTooltipData;
    expect(tooltipData.getTooltipItems, isNotNull);

    final barData = LineChartBarData(spots: [const FlSpot(0, 68.0)]);
    final tooltipItems = tooltipData.getTooltipItems([
      LineBarSpot(barData, 0, const FlSpot(0, 68.0)),
    ]);

    expect(tooltipItems, isNotNull);
    final firstItem = tooltipItems.first;
    expect(firstItem, isNotNull);
    expect(
      firstItem!.children?.any(
        (span) => span.toPlainText().contains('Temperature: 68.0°F'),
      ),
      isTrue,
    );
  });
}
