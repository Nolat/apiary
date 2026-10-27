// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy_countdown.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How long until the next unit of energy, in whole seconds (rounded up, so
/// it never shows 0:00); `null` when the gauge is full or no trusted time is
/// known.

@ProviderFor(EnergyCountdown)
final energyCountdownProvider = EnergyCountdownProvider._();

/// How long until the next unit of energy, in whole seconds (rounded up, so
/// it never shows 0:00); `null` when the gauge is full or no trusted time is
/// known.
final class EnergyCountdownProvider
    extends $NotifierProvider<EnergyCountdown, Duration?> {
  /// How long until the next unit of energy, in whole seconds (rounded up, so
  /// it never shows 0:00); `null` when the gauge is full or no trusted time is
  /// known.
  EnergyCountdownProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'energyCountdownProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$energyCountdownHash();

  @$internal
  @override
  EnergyCountdown create() => EnergyCountdown();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration?>(value),
    );
  }
}

String _$energyCountdownHash() => r'8c551b8899543bdd065b64d77f0e4e540439eec3';

/// How long until the next unit of energy, in whole seconds (rounded up, so
/// it never shows 0:00); `null` when the gauge is full or no trusted time is
/// known.

abstract class _$EnergyCountdown extends $Notifier<Duration?> {
  Duration? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Duration?, Duration?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Duration?, Duration?>,
              Duration?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
