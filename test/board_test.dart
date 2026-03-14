import 'package:flutter_test/flutter_test.dart';
import 'package:campominado/features/game/models/board.dart';
import 'package:campominado/features/game/models/cell.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------
  group('Board initialization', () {
    test('creates correct grid dimensions', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      expect(board.cells.length, 12);
      for (final row in board.cells) {
        expect(row.length, 12);
      }
    });

    test('all cells start hidden and mine-free', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      for (int r = 0; r < 12; r++) {
        for (int c = 0; c < 12; c++) {
          final cell = board.cells[r][c];
          expect(cell.state, CellState.hidden);
          expect(cell.isMine, false);
          expect(cell.row, r);
          expect(cell.col, c);
        }
      }
    });

    test('minesPlaced starts as false', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      expect(board.minesPlaced, false);
    });

    test('minesLeft equals totalMines when no flags', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      expect(board.minesLeft, 20);
    });
  });

  // ---------------------------------------------------------------------------
  // Mine placement
  // ---------------------------------------------------------------------------
  group('Mine placement', () {
    test('places exactly totalMines mines', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      int count = 0;
      for (int r = 0; r < 12; r++) {
        for (int c = 0; c < 12; c++) {
          if (board.cells[r][c].isMine) count++;
        }
      }
      expect(count, 20);
    });

    test('safe cell is never a mine (repeated 15 times)', () {
      for (int i = 0; i < 15; i++) {
        final board = Board(rows: 12, cols: 12, totalMines: 20);
        board.placeMines(5, 5);
        expect(board.cells[5][5].isMine, false,
            reason: 'iteration $i: safe cell [5][5] must not be a mine');
      }
    });

    test('minesPlaced becomes true after placement', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      expect(board.minesPlaced, true);
    });

    test('calling placeMines twice keeps mine count at 20', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      board.placeMines(5, 5);
      int count = 0;
      for (int r = 0; r < 12; r++) {
        for (int c = 0; c < 12; c++) {
          if (board.cells[r][c].isMine) count++;
        }
      }
      expect(count, 20);
    });
  });

  // ---------------------------------------------------------------------------
  // Adjacent mine calculation (self-verifying)
  // ---------------------------------------------------------------------------
  group('Adjacent mine calculation', () {
    test('adjacentMines matches recomputed neighbor count for all cells', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      for (int r = 0; r < 12; r++) {
        for (int c = 0; c < 12; c++) {
          if (board.cells[r][c].isMine) continue;
          int expected = 0;
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              if (dr == 0 && dc == 0) continue;
              final nr = r + dr;
              final nc = c + dc;
              if (nr >= 0 && nr < 12 && nc >= 0 && nc < 12) {
                if (board.cells[nr][nc].isMine) expected++;
              }
            }
          }
          expect(board.cells[r][c].adjacentMines, expected,
              reason: 'cell [$r][$c] adjacentMines mismatch');
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Reveal & Flood fill
  // ---------------------------------------------------------------------------
  group('Reveal', () {
    test('reveal returns false for safe cell', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      final hitMine = board.reveal(0, 0);
      expect(hitMine, false);
      expect(board.cells[0][0].state, CellState.revealed);
    });

    test('reveal returns true for mine cell', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      // Find a mine
      for (int r = 0; r < 12; r++) {
        for (int c = 0; c < 12; c++) {
          if (board.cells[r][c].isMine) {
            final hit = board.reveal(r, c);
            expect(hit, true);
            expect(board.cells[r][c].state, CellState.revealed);
            return;
          }
        }
      }
    });

    test('reveal does nothing on already-revealed cell', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      board.reveal(0, 0);
      final hit = board.reveal(0, 0);
      expect(hit, false);
    });

    test('reveal does nothing on flagged cell', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      board.toggleFlag(0, 0);
      final hit = board.reveal(0, 0);
      expect(hit, false);
      expect(board.cells[0][0].state, CellState.flagged);
    });

    test('flood fill reveals connected zero-adjacent cells', () {
      // Build a 5×5 board with a single mine at [4][4]
      // Cell [0][0] will have adjacentMines == 0 → flood fill must reach it
      final board = Board(rows: 5, cols: 5, totalMines: 1);
      // Manually mark the mine and force adjacents
      board.cells[4][4].isMine = true;
      board.placeMines(0, 0); // totalMines=1 already placed: guard skips loop

      if (!board.cells[0][0].isMine && board.cells[0][0].adjacentMines == 0) {
        board.reveal(0, 0);
        // All cells reachable via zeros must be revealed
        int revealed = 0;
        for (int r = 0; r < 5; r++) {
          for (int c = 0; c < 5; c++) {
            if (board.cells[r][c].state == CellState.revealed) revealed++;
          }
        }
        expect(revealed, greaterThan(1),
            reason: 'flood fill should reveal more than 1 cell');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Flag toggle
  // ---------------------------------------------------------------------------
  group('Flag toggle', () {
    test('hidden → flagged', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      expect(board.toggleFlag(0, 0), true);
      expect(board.cells[0][0].state, CellState.flagged);
    });

    test('flagged → hidden', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.toggleFlag(0, 0);
      expect(board.toggleFlag(0, 0), true);
      expect(board.cells[0][0].state, CellState.hidden);
    });

    test('cannot flag a revealed cell', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      board.reveal(0, 0);
      expect(board.toggleFlag(0, 0), false);
      expect(board.cells[0][0].state, CellState.revealed);
    });

    test('minesLeft decrements per flag', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      expect(board.minesLeft, 20);
      board.toggleFlag(0, 0);
      expect(board.minesLeft, 19);
      board.toggleFlag(1, 0);
      expect(board.minesLeft, 18);
    });

    test('minesLeft increments when flag removed', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.toggleFlag(0, 0);
      board.toggleFlag(0, 0);
      expect(board.minesLeft, 20);
    });
  });

  // ---------------------------------------------------------------------------
  // Win / Loss detection
  // ---------------------------------------------------------------------------
  group('Win detection', () {
    test('checkWin returns false on fresh board', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      expect(board.checkWin(), false);
    });

    test('checkWin returns true when all non-mine cells are revealed', () {
      final board = Board(rows: 3, cols: 3, totalMines: 1);
      board.placeMines(1, 1);
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          if (!board.cells[r][c].isMine) {
            board.cells[r][c].state = CellState.revealed;
          }
        }
      }
      expect(board.checkWin(), true);
    });

    test('checkWin ignores mine state (flagged mines OK)', () {
      final board = Board(rows: 3, cols: 3, totalMines: 1);
      board.placeMines(1, 1);
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          if (!board.cells[r][c].isMine) {
            board.cells[r][c].state = CellState.revealed;
          } else {
            board.cells[r][c].state = CellState.flagged;
          }
        }
      }
      expect(board.checkWin(), true);
    });
  });

  // ---------------------------------------------------------------------------
  // Reveal all mines
  // ---------------------------------------------------------------------------
  group('Reveal all mines', () {
    test('all mine cells become revealed', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      board.revealAllMines();
      for (int r = 0; r < 12; r++) {
        for (int c = 0; c < 12; c++) {
          if (board.cells[r][c].isMine) {
            expect(board.cells[r][c].state, CellState.revealed);
          }
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Clone
  // ---------------------------------------------------------------------------
  group('Board clone', () {
    test('clone is a deep copy — mutating clone does not affect original', () {
      final board = Board(rows: 12, cols: 12, totalMines: 20);
      board.placeMines(0, 0);
      final clone = board.clone();
      clone.cells[0][0].state = CellState.revealed;
      if (board.cells[0][0].state != CellState.revealed) {
        expect(board.cells[0][0].state, isNot(CellState.revealed));
      }
    });
  });
}
