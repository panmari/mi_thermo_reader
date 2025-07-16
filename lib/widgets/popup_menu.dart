import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_review_plus/app_review_plus.dart';

enum Selection { about, rate, fixTime }

/// For retrieving PackageInfo async, the actual PopupMenu is wrapped
/// in this stateful widget.
class PopupMenu extends StatefulWidget {
  final Function? getAndFixTime;

  const PopupMenu({super.key, this.getAndFixTime});

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) {
        return PopupMenuButton<Selection>(
          onSelected: (Selection result) {
            switch (result) {
              case Selection.about:
                showAboutDialog(
                  context: context,
                  applicationIcon: Image.asset(
                    'assets/icon/icon.png',
                    height: 50,
                  ),
                  applicationName: "Mi Thermometer Reader",
                  applicationLegalese: '© 2025 panmari',
                  applicationVersion: snapshot.data?.version ?? 'Unknown',
                  children: [
                    Container(padding: const EdgeInsets.fromLTRB(0, 10, 0, 10)),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          const TextSpan(
                            text:
                                'After patching your device with the firmware from ',
                          ),
                          TextSpan(
                            text: 'https://github.com/pvvx/ATC_MiThermometer',
                            style: const TextStyle(color: Colors.lightBlue),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse(
                                        'https://github.com/pvvx/ATC_MiThermometer',
                                      ),
                                    );
                                  },
                          ),
                          const TextSpan(text: ' or '),
                          TextSpan(
                            text: 'https://github.com/pvvx/THB2',
                            style: const TextStyle(color: Colors.lightBlue),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse('https://github.com/pvvx/THB2'),
                                    );
                                  },
                          ),
                          const TextSpan(
                            text:
                                ', it becomes supercharged with a bunch of great capabilites. Most importantly, it saves sensor values to device at fixed intervals.\n\nMi Thermometer Reader helps with reading and visualizing all data stored on the device.\n',
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          () => launchUrl(
                            Uri.parse(
                              'https://github.com/panmari/mi_thermo_reader',
                            ),
                          ),
                      child: Text('Source on Github'),
                    ),
                  ],
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
      if (!kIsWeb)
        PopupMenuItem<Selection>(
          value: Selection.rate,
          child: Text('Rate this app'),
        ),
      PopupMenuItem<Selection>(value: Selection.about, child: Text('About')),
    ];
  }
}
