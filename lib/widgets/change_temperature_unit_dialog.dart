import 'package:flutter/material.dart';
import 'package:open_settings_plus/open_settings_plus.dart';

class ChangeTemperatureUnitDialog extends StatelessWidget {
  const ChangeTemperatureUnitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Temperature Unit'),
      content: const Text(
        'To change the temperature unit, scroll down in the settings menu to "Regional Preferences" and set the desired temperature unit there.',
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Open Settings'),
          onPressed: () {
            Navigator.of(context).pop();
            final _ = switch (OpenSettingsPlus.shared) {
              // Directly linking to https://developer.android.com/reference/android/provider/Settings#ACTION_REGIONAL_PREFERENCES_SETTINGS didn't work on my tester phone.
              OpenSettingsPlusAndroid settings => settings.locale(),
              OpenSettingsPlusIOS settings => settings.languageAndRegion(),
              _ => throw Exception('Platform not supported'),
            };
          },
        ),
      ],
    );
  }
}
