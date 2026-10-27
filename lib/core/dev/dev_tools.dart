/// What the dev screen can do and what opens it, handed to the game by
/// `bootstrap()`. Without it, the game has no dev screen (tests).
class DevTools {
  const DevTools({
    required this.resetDatabase,
    this.shakes = const Stream<void>.empty(),
  });

  /// Erases everything the app keeps in its local database.
  final Future<void> Function() resetDatabase;

  /// Emits each time the player shakes the phone.
  final Stream<void> shakes;
}
