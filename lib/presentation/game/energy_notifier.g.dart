// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The energy gauge of the game in progress, shared by what spends it (the
/// board) and what shows it (the HUD): the state is the single copy, saved
/// after each change, and recharged over time on the [trustedClock]'s time.
/// The game calls [update] every frame.
///
/// Without a repository nothing is saved, and without a clock nothing is
/// recharged: tests play on a gauge that only goes down.

@ProviderFor(EnergyNotifier)
final energyProvider = EnergyNotifierProvider._();

/// The energy gauge of the game in progress, shared by what spends it (the
/// board) and what shows it (the HUD): the state is the single copy, saved
/// after each change, and recharged over time on the [trustedClock]'s time.
/// The game calls [update] every frame.
///
/// Without a repository nothing is saved, and without a clock nothing is
/// recharged: tests play on a gauge that only goes down.
final class EnergyNotifierProvider
    extends $NotifierProvider<EnergyNotifier, Energy> {
  /// The energy gauge of the game in progress, shared by what spends it (the
  /// board) and what shows it (the HUD): the state is the single copy, saved
  /// after each change, and recharged over time on the [trustedClock]'s time.
  /// The game calls [update] every frame.
  ///
  /// Without a repository nothing is saved, and without a clock nothing is
  /// recharged: tests play on a gauge that only goes down.
  EnergyNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'energyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$energyNotifierHash();

  @$internal
  @override
  EnergyNotifier create() => EnergyNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Energy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Energy>(value),
    );
  }
}

String _$energyNotifierHash() => r'68160180a8b75c961cbb6662afe3dd2002ca9bf4';

/// The energy gauge of the game in progress, shared by what spends it (the
/// board) and what shows it (the HUD): the state is the single copy, saved
/// after each change, and recharged over time on the [trustedClock]'s time.
/// The game calls [update] every frame.
///
/// Without a repository nothing is saved, and without a clock nothing is
/// recharged: tests play on a gauge that only goes down.

abstract class _$EnergyNotifier extends $Notifier<Energy> {
  Energy build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Energy, Energy>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Energy, Energy>,
              Energy,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
