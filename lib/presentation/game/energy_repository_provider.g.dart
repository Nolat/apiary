// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the energy gauge is saved; `null` keeps it in memory, as in tests.
/// The app assembles the real one by overriding this provider (`bootstrap()`),
/// so that a read before the launch has registered it fails loudly instead of
/// settling on `null` for the whole session.

@ProviderFor(energyRepository)
final energyRepositoryProvider = EnergyRepositoryProvider._();

/// Where the energy gauge is saved; `null` keeps it in memory, as in tests.
/// The app assembles the real one by overriding this provider (`bootstrap()`),
/// so that a read before the launch has registered it fails loudly instead of
/// settling on `null` for the whole session.

final class EnergyRepositoryProvider
    extends
        $FunctionalProvider<
          EnergyRepository?,
          EnergyRepository?,
          EnergyRepository?
        >
    with $Provider<EnergyRepository?> {
  /// Where the energy gauge is saved; `null` keeps it in memory, as in tests.
  /// The app assembles the real one by overriding this provider (`bootstrap()`),
  /// so that a read before the launch has registered it fails loudly instead of
  /// settling on `null` for the whole session.
  EnergyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'energyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$energyRepositoryHash();

  @$internal
  @override
  $ProviderElement<EnergyRepository?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EnergyRepository? create(Ref ref) {
    return energyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnergyRepository? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnergyRepository?>(value),
    );
  }
}

String _$energyRepositoryHash() => r'e22db4061d736b66e8760e44d066b023507cddcc';
