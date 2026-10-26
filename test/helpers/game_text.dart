// 🎯 Dart imports:
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/services.dart' show FontLoader, rootBundle;

// 📦 Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';

// 🌎 Project imports:
import 'package:apiary/presentation/components/board/item_info_component.dart';

/// Loads what `flutter test` leaves out and the game's texts need: the
/// project's pixel font (otherwise text renders as the test font's solid
/// blocks) and the French strings (otherwise `tr()` returns the keys).
/// Call it in `setUpAll`, inside `runAsync` for a widget test.
Future<void> loadGameText() async {
  await (FontLoader(
    ItemInfoComponent.fontFamily,
  )..addFont(rootBundle.load('assets/fonts/BoldPixels.ttf'))).load();
  final french = await const RootBundleAssetLoader().load(
    'assets/translations',
    const Locale('fr'),
  );
  Localization.load(const Locale('fr'), translations: Translations(french));
}
