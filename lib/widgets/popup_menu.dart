import 'dart:convert';
import 'dart:developer' as developer;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_thermo_reader/utils/sensor_entry.dart';
import 'package:mi_thermo_reader/widgets/about_dialog.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:app_review_plus/app_review_plus.dart';

enum Selection { about, rate, fixTime, export }

/// For retrieving PackageInfo async, the actual PopupMenu is wrapped
/// in this stateful widget.
class PopupMenu extends StatefulWidget {
  final Function? getAndFixTime;
  final List<SensorEntry>? sensorEntries;

  const PopupMenu({super.key, this.getAndFixTime, this.sensorEntries});

  @override
  State<PopupMenu> createState() => _PopupMenuState();
}

class _PopupMenuState extends State<PopupMenu> {
  Future<PackageInfo>? _packageInfo;

  @override
  void initState() {
    super.initState();
    setState(() {
      _packageInfo = PackageInfo.fromPlatform();
    });
  }

  String _sensorEntriesToCsv(List<SensorEntry> entries) {
    final buffer = StringBuffer();
    // Header
    buffer.writeln('timestamp,temperature,humidity,voltageBattery');
    // Data
    for (final entry in entries) {
      buffer.writeln(
        '${entry.timestamp.toIso8601String()},${entry.temperature.toStringAsFixed(2)},${entry.humidity.toStringAsFixed(2)},${entry.voltageBattery}',
      );
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) {
        return PopupMenuButton<Selection>(
          onSelected: (Selection result) async {
            switch (result) {
              case Selection.about:
                showDialog(
                  context: context,
                  builder:
                      (context) => MiThermoReaderAboutDialog(
                        version: snapshot.data?.version ?? 'Unknown',
                      ),
                );
                break;
              case Selection.rate:
                AppReview.requestReview.then((onValue) {
                  developer.log('Value from rating app: $onValue');
                });
                break;
              case Selection.fixTime:
                widget.getAndFixTime!();
                break;
              case Selection.export:
                if (widget.sensorEntries != null &&
                    widget.sensorEntries!.isNotEmpty) {
                  final csvData = _sensorEntriesToCsv(widget.sensorEntries!);
                  final now = DateTime.now();
                  final formatter = DateFormat('yyyy-MM-dd');
                  final formattedDate = formatter.format(now);
                  final filename = 'mi_thermo_reader_export_$formattedDate';

                  await FileSaver.instance.saveFile(
                    name: filename,
                    bytes: Uint8List.fromList(utf8.encode(csvData)),
                    fileExtension: 'csv',
                    mimeType: MimeType.csv,
                  );
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) => _menuItemBuilder(context),
        );
      },
    );
  }

  List<PopupMenuEntry<Selection>> _menuItemBuilder(BuildContext context) {
    return [
      if (widget.getAndFixTime != null)
        PopupMenuItem<Selection>(
          value: Selection.fixTime,
          child: Text('Adjust time'),
        ),
      if (widget.sensorEntries != null && widget.sensorEntries!.isNotEmpty)
        const PopupMenuItem<Selection>(
          value: Selection.export,
          child: Text('Export to CSV'),
        ),
      if (!kIsWeb)
        PopupMenuItem<Selection>(
          value: Selection.rate,
          child: Text('Rate this app'),
        ),
      PopupMenuItem<Selection>(value: Selection.about, child: Text('About')),
    ];
  }
}
