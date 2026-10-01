import 'package:region_settings/region_settings.dart';

/// Extension on [double] to allow `value.inUnit(unit)` directly on raw
/// Celsius temperature doubles.
/// This is needed because we want to directly work with proto wrappers,
/// which only support primitive types.
extension TemperatureDoubleExtension on double {
  /// Returns this value (assumed to be in Celsius) converted to [unit].
  double inUnit(TemperatureUnit unit) {
    if (unit == TemperatureUnit.celsius) {
      return this;
    }
    return (this * 9 / 5) + 32;
  }
}
