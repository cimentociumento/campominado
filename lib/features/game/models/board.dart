import 'dart:collection';
import 'dart:math';
import 'cell.dart';

class Board {
  final int rows;
  final int cols;
  final int totalMines;

  late List<List<Cell>> cells;
  bool _minesPlaced = false;

  Board({
    required this.rows,
    required this.cols,
    required this.totalMines,
  }) {
    _init();
  }

  Board._internal({
    required this.rows,
    required this.cols,
    required this.totalMines,
    required this.cells,
    required bool minesPlaced,
  }) : _minesPlaced = minesPlaced;

  void _init() {
    cells = List.generate(
      rows,
      (r) => List.generate(cols, (c) => Cell(row: r, col: c)),
    );
    _minesPlaced = false;
  }

  Board clone() {
    return Board._internal(
      rows: rows,
      cols: cols,
      totalMines: totalMines,
      cells: List.generate(
        rows,
        (r) => List.generate(cols, (c) => cells[r][c].clone()),
      ),
      minesPlaced: _minesPlaced,
    );
  }

  bool get minesPlaced => _minesPlaced;

  void placeMines(int safeRow, int safeCol) {
    if (_minesPlaced) return;
    final random = Random();
    int placed = 0;
    while (placed < totalMines) {
      final r = random.nextInt(rows);
      final c = random.nextInt(cols);
      if ((r != safeRow || c != safeCol) && !cells[r][c].isMine) {
        cells[r][c].isMine = true;
        placed++;
      }
    }
    _calculateAdjacents();
    _minesPlaced = true;
  }

  void _calculateAdjacents() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!cells[r][c].isMine) {
          cells[r][c].adjacentMines = _countAdjacent(r, c);
        }
      }
    }
  }

  int _countAdjacent(int row, int col) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final r = row + dr;
        final c = col + dc;
        if (_inBounds(r, c) && cells[r][c].isMine) count++;
      }
    }
    return count;
  }

  bool _inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  /// Returns true if a mine was hit. Must call [placeMines] first.
  bool reveal(int row, int col) {
    final cell = cells[row][col];
    if (cell.state != CellState.hidden) return false;
    if (cell.isMine) {
      cell.state = CellState.revealed;
      return true;
    }
    _floodReveal(row, col);
    return false;
  }

  void _floodReveal(int startRow, int startCol) {
    final queue = Queue<(int, int)>();
    queue.add((startRow, startCol));
    final visited = <(int, int)>{};

    while (queue.isNotEmpty) {
      final (r, c) = queue.removeFirst();
      if (visited.contains((r, c))) continue;
      visited.add((r, c));

      final cell = cells[r][c];
      if (cell.state != CellState.hidden) continue;
      cell.state = CellState.revealed;

      if (cell.adjacentMines == 0) {
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            final nr = r + dr;
            final nc = c + dc;
            if (_inBounds(nr, nc) &&
                cells[nr][nc].state == CellState.hidden &&
                !cells[nr][nc].isMine) {
              queue.add((nr, nc));
            }
          }
        }
      }
    }
  }

  bool toggleFlag(int row, int col) {
    final cell = cells[row][col];
    if (cell.state == CellState.hidden) {
      cell.state = CellState.flagged;
      return true;
    } else if (cell.state == CellState.flagged) {
      cell.state = CellState.hidden;
      return true;
    }
    return false;
  }

  bool checkWin() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (!cells[r][c].isMine &&
            cells[r][c].state != CellState.revealed) {
          return false;
        }
      }
    }
    return true;
  }

  void revealAllMines() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (cells[r][c].isMine) {
          cells[r][c].state = CellState.revealed;
        }
      }
    }
  }

  int get minesLeft {
    int flagged = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (cells[r][c].state == CellState.flagged) flagged++;
      }
    }
    return totalMines - flagged;
  }
}
