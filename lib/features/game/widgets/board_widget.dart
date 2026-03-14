import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/game_controller.dart';
import '../models/board.dart';
import 'cell_widget.dart';

class BoardWidget extends ConsumerWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final notifier = ref.read(gameControllerProvider.notifier);
    final board = gameState.board;
    final isLost = gameState.status == GameStatus.lost;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = _cellSize(constraints, board);
        return SizedBox(
          width: cellSize * board.cols,
          height: cellSize * board.rows,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              board.rows,
              (r) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  board.cols,
                  (c) {
                    final cell = board.cells[r][c];
                    final isDetonated = isLost &&
                        cell.isMine &&
                        cell.isRevealed;
                    return CellWidget(
                      key: ValueKey('$r-$c'),
                      cell: cell,
                      size: cellSize,
                      isDetonated: isDetonated,
                      onReveal: (gameState.status == GameStatus.lost ||
                              gameState.status == GameStatus.won)
                          ? null
                          : () => notifier.reveal(r, c),
                      onFlag: (gameState.status == GameStatus.lost ||
                              gameState.status == GameStatus.won)
                          ? null
                          : () => notifier.toggleFlag(r, c),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _cellSize(BoxConstraints constraints, Board board) {
    final maxW = constraints.maxWidth / board.cols;
    final maxH = constraints.maxHeight / board.rows;
    return min(maxW, maxH).clamp(28.0, 64.0);
  }
}
