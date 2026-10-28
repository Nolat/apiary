// 🌎 Project imports:
import 'package:apiary/domain/bees/family.dart';
import 'package:apiary/domain/board/board.dart';
import 'package:apiary/domain/board/board_item.dart';
import 'package:apiary/domain/board/board_position.dart';

/// The starting board with [bee] in its hive.
Board boardWithBeeInHive(Bee bee) => Board.initial().copyWith(
  items: {
    ...Board.initial().items,
    Board.startingHivePosition: BoardItem.hive(bee: bee),
  },
);

/// A board with no free cell, the hive holding [bee].
Board fullBoardWithBeeInHive(Bee bee) => Board(
  items: {
    for (var column = 0; column < Board.columns; column++)
      for (var row = 0; row < Board.rows; row++)
        BoardPosition(column: column, row: row): const BoardItem.larva(
          family: Family.honeybee,
        ),
    Board.startingHivePosition: BoardItem.hive(bee: bee),
  },
);
