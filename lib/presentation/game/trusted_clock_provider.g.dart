// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The time the energy recharge is measured on; `null` recharges nothing, as
/// in tests. Assembled by overriding it, like `energyRepository`.

@ProviderFor(trustedClock)
final trustedClockProvider = TrustedClockProvider._();

/// The time the energy recharge is measured on; `null` recharges nothing, as
/// in tests. Assembled by overriding it, like `energyRepository`.

final class TrustedClockProvider
    extends $FunctionalProvider<TrustedClock?, TrustedClock?, TrustedClock?>
    with $Provider<TrustedClock?> {
  /// The time the energy recharge is measured on; `null` recharges nothing, as
  /// in tests. Assembled by overriding it, like `energyRepository`.
  TrustedClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustedClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustedClockHash();

  @$internal
  @override
  $ProviderElement<TrustedClock?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrustedClock? create(Ref ref) {
    return trustedClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrustedClock? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrustedClock?>(value),
    );
  }
}

String _$trustedClockHash() => r'5ac745acb12f4100000f1c1da1410163b8667c2c';
