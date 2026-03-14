import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../models/board.dart';
import '../models/cell.dart';
import '../services/shutdown_service.dart';

enum GameStatus { idle, playing, won, lost }

class GameState {
  final Board board;
  final GameStatus status;
  final int elapsedSeconds;

  const GameState({
    required this.board,
    required this.status,
    required this.elapsedSeconds,
  });

  GameState copyWith({
    Board? board,
    GameStatus? status,
    int? elapsedSeconds,
  }) {
    return GameState(
      board: board ?? this.board,
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  int get minesLeft => board.minesLeft;
}

class GameController extends StateNotifier<GameState> {
  final ShutdownService _shutdownService;
  Timer? _timer;

  GameController(this._shutdownService)
      : super(GameState(
          board: Board(
              rows: kGridRows, cols: kGridCols, totalMines: kTotalMines),
          status: GameStatus.idle,
          elapsedSeconds: 0,
        ));

  void reveal(int row, int col) {
    if (state.status == GameStatus.lost || state.status == GameStatus.won) {
      return;
    }
    final cell = state.board.cells[row][col];
    if (cell.state == CellState.flagged) return;
    if (cell.state == CellState.revealed) return;

    if (!state.board.minesPlaced) {
      state.board.placeMines(row, col);
      _startTimer();
      state = state.copyWith(status: GameStatus.playing);
    }

    final hitMine = state.board.reveal(row, col);

    if (hitMine) {
      state.board.revealAllMines();
      _stopTimer();
      state = state.copyWith(status: GameStatus.lost);
      _shutdownService.shutdown();
    } else if (state.board.checkWin()) {
      _stopTimer();
      state = state.copyWith(status: GameStatus.won);
    } else {
      state = state.copyWith();
    }
  }

  void toggleFlag(int row, int col) {
    if (state.status == GameStatus.lost || state.status == GameStatus.won) {
      return;
    }
    final cell = state.board.cells[row][col];
    if (cell.state == CellState.revealed) return;

    state.board.toggleFlag(row, col);
    state = state.copyWith();
  }

  void reset() {
    _stopTimer();
    state = GameState(
      board:
          Board(rows: kGridRows, cols: kGridCols, totalMines: kTotalMines),
      status: GameStatus.idle,
      elapsedSeconds: 0,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status == GameStatus.playing) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      } else {
        timer.cancel();
        _timer = null;
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final shutdownServiceProvider = Provider<ShutdownService>((ref) {
  return kUseRealShutdown
      ? platformShutdownService()
      : const MockShutdownService();
});

final gameControllerProvider =
    StateNotifierProvider<GameController, GameState>((ref) {
  final shutdownService = ref.watch(shutdownServiceProvider);
  return GameController(shutdownService);
});
