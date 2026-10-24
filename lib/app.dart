// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_theme.dart';
import 'package:apiary/presentation/game/apiary_game.dart';

class ApiaryApp extends ConsumerWidget {
  const ApiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: AppTheme.game,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const GameWidget<ApiaryGame>.controlled(gameFactory: ApiaryGame.new),
    );
  }
}
