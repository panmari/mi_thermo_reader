// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fetchSharedPreferences)
final fetchSharedPreferencesProvider = FetchSharedPreferencesProvider._();

final class FetchSharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferencesWithCache>,
          SharedPreferencesWithCache,
          FutureOr<SharedPreferencesWithCache>
        >
    with
        $FutureModifier<SharedPreferencesWithCache>,
        $FutureProvider<SharedPreferencesWithCache> {
  FetchSharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fetchSharedPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fetchSharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferencesWithCache> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferencesWithCache> create(Ref ref) {
    return fetchSharedPreferences(ref);
  }
}

String _$fetchSharedPreferencesHash() =>
    r'b7f872dbd86d487b3c62af8c3c176105a89ea6e1';

@ProviderFor(fetchTemperatureUnit)
final fetchTemperatureUnitProvider = FetchTemperatureUnitProvider._();

final class FetchTemperatureUnitProvider
    extends
        $FunctionalProvider<
          AsyncValue<TemperatureUnit>,
          TemperatureUnit,
          FutureOr<TemperatureUnit>
        >
    with $FutureModifier<TemperatureUnit>, $FutureProvider<TemperatureUnit> {
  FetchTemperatureUnitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fetchTemperatureUnitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fetchTemperatureUnitHash();

  @$internal
  @override
  $FutureProviderElement<TemperatureUnit> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TemperatureUnit> create(Ref ref) {
    return fetchTemperatureUnit(ref);
  }
}

String _$fetchTemperatureUnitHash() =>
    r'91a9d1282a3eca1e80b973206983e8ac213bca04';
