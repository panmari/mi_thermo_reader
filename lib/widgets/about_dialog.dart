import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MiThermoReaderAboutDialog extends StatelessWidget {
  const MiThermoReaderAboutDialog({super.key, required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return AboutDialog(
      applicationIcon: Image.asset(
        'assets/icon/icon.png',
        height: 50,
      ),
      applicationName: "Mi Thermometer Reader",
      applicationLegalese: '© 2025 panmari',
      applicationVersion: version,
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
                    ', it becomes supercharged with a bunch of great capabilities. Most importantly, it saves sensor values to device at fixed intervals.\n\nMi Thermometer Reader helps with reading and visualizing all data stored on the device.\n',
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
  }
}
