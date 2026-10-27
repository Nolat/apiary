// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 🌎 Project imports:
import 'package:apiary/core/startup/game_services.dart';
import 'package:apiary/core/startup/startup_step.dart';

/// The launch of the app, which runs behind the splash screen: the work to do
/// (handed over by `bootstrap()`) and where it stands, for the splash to show.
/// Without a [Startup], the game opens straight on the board (tests).
class Startup {
  Startup(this._start);

  final Future<GameServices> Function(ValueNotifier<StartupStep> step) _start;

  /// The step being run. The work reports its own steps; the game reports the
  /// ones it does itself.
  final ValueNotifier<StartupStep> step = ValueNotifier(StartupStep.services);

  /// Whether the launch failed: the splash then says so instead of the step.
  final ValueNotifier<bool> failed = ValueNotifier(false);

  /// Starts the services, reporting each step on [step].
  Future<GameServices> run() => _start(step);
}
