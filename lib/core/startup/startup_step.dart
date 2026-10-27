/// The steps of the launch, in order. The splash screen shows the current one:
/// its [labelKey] under the loading bar, which fills as the steps go by.
enum StartupStep {
  services('startup.services'),
  account('startup.account'),
  board('startup.board'),
  ready('startup.ready');

  const StartupStep(this.labelKey);

  /// The translation key of what the step is doing.
  final String labelKey;

  /// How full the loading bar is while this step runs: each step fills its
  /// share at the start, so the bar never sits empty, and [ready] is full.
  double get progress => (index + 1) / values.length;
}
