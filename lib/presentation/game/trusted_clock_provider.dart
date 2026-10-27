// 📦 Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 🌎 Project imports:
import 'package:apiary/domain/energy/trusted_clock.dart';

part 'trusted_clock_provider.g.dart';

/// The time the energy recharge is measured on; `null` recharges nothing, as
/// in tests. Assembled by overriding it, like `energyRepository`.
@Riverpod(keepAlive: true)
TrustedClock? trustedClock(Ref ref) => null;
