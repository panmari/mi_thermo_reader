// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(fetchSharedPreferences)
const fetchSharedPreferencesProvider = FetchSharedPreferencesProvider._();

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
  const FetchSharedPreferencesProvider._()
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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
