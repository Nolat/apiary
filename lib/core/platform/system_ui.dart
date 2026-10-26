// 🐦 Flutter imports:
import 'package:flutter/services.dart';

/// Full-screen, portrait-only display: the game is a portrait pixel-art
/// canvas, 140 game pixels wide (see docs/DESIGN.md), so the OS status and
/// navigation bars are hidden. In sticky immersive mode a swipe from an edge
/// reveals them for a moment, then they hide again on their own.
///
/// The native launch configuration (`ios/Runner/Info.plist`, Android
/// `styles.xml` and `AndroidManifest.xml`) does the same before Flutter
/// starts, so the splash screen doesn't show the bars either.
Future<void> configureSystemUi() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}
