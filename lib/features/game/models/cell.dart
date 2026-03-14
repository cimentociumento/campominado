enum CellState { hidden, revealed, flagged }

class Cell {
  final int row;
  final int col;
  bool isMine;
  int adjacentMines;
  CellState state;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.adjacentMines = 0,
    this.state = CellState.hidden,
  });

  bool get isRevealed => state == CellState.revealed;
  bool get isFlagged => state == CellState.flagged;
  bool get isHidden => state == CellState.hidden;

  Cell clone() => Cell(
        row: row,
        col: col,
        isMine: isMine,
        adjacentMines: adjacentMines,
        state: state,
      );
}
