// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:apiary/core/theme/app_theme.dart';
import 'package:apiary/domain/board/board_repository.dart';
import 'package:apiary/presentation/game/apiary_game.dart';
import 'package:apiary/presentation/game/layout_debug_overlay.dart';

class ApiaryApp extends ConsumerWidget {
  const ApiaryApp({this.boardRepository, super.key});

  /// Where the board is kept; `null` plays without saving (tests).
  final BoardRepository? boardRepository;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: AppTheme.game,
      // The debug banner would cover the layout test card's corner. Only
      // redundant (true) when the card is off, which depends on the build.
      // ignore: avoid_redundant_argument_values
      debugShowCheckedModeBanner: !LayoutDebugOverlay.enabled,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // Full screen, notch included: the game's viewport keeps its reference
      // area inside the safe area itself (see GameViewport).
      home: GameWidget<ApiaryGame>.controlled(
        gameFactory: () => ApiaryGame(boardRepository: boardRepository),
      ),
    );
  }
}
