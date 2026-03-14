import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campominado/features/game/controllers/game_controller.dart';
import 'package:campominado/features/game/models/cell.dart';
import 'package:campominado/features/game/services/shutdown_service.dart';

class _TrackingShutdownService implements ShutdownService {
  bool wasShutdownCalled = false;

  @override
  Future<void> shutdown() async {
    wasShutdownCalled = true;
  }
}

ProviderContainer _makeContainer({ShutdownService? shutdownService}) {
  return ProviderContainer(
    overrides: [
      shutdownServiceProvider.overrideWithValue(
        shutdownService ?? const MockShutdownService(),
      ),
    ],
  );
}

void main() {
  // ---------------------------------------------------------------------------
  // Initial state
  // ---------------------------------------------------------------------------
  group('Initial state', () {
    test('status is idle, 0 seconds, 20 mines left, no mines placed', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final state = container.read(gameControllerProvider);

      expect(state.status, GameStatus.idle);
      expect(state.elapsedSeconds, 0);
      expect(state.minesLeft, 20);
      expect(state.board.minesPlaced, false);
    });
  });

  // ---------------------------------------------------------------------------
  // First click (idle → playing)
  // ---------------------------------------------------------------------------
  group('First click', () {
    test('transitions status from idle to playing', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(gameControllerProvider.notifier).reveal(5, 5);
      final state = container.read(gameControllerProvider);
      expect(state.status, GameStatus.playing);
    });

    test('places mines after first click', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(gameControllerProvider.notifier).reveal(5, 5);
      expect(container.read(gameControllerProvider).board.minesPlaced, true);
    });

    test('first click cell is always revealed (never a mine)', () {
      for (int i = 0; i < 10; i++) {
        final container = _makeContainer();
        addTearDown(container.dispose);
        container.read(gameControllerProvider.notifier).reveal(6, 3);
        final state = container.read(gameControllerProvider);
        expect(state.board.cells[6][3].isMine, false,
            reason: 'iteration $i: first-click cell must not be a mine');
        expect(state.board.cells[6][3].state, CellState.revealed);
      }
    });

    test('clicking an already-revealed cell does nothing', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameControllerProvider.notifier);
      notifier.reveal(5, 5);
      final boardAfterFirst =
          container.read(gameControllerProvider).board.clone();
      notifier.reveal(5, 5);
      final state = container.read(gameControllerProvider);
      expect(state.board.cells[5][5].state,
          boardAfterFirst.cells[5][5].state);
    });
  });

  // ---------------------------------------------------------------------------
  // Flag toggle
  // ---------------------------------------------------------------------------
  group('Flag toggle', () {
    test('flagging a hidden cell decrements minesLeft', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameControllerProvider.notifier);
      notifier.reveal(5, 5);

      final board = container.read(gameControllerProvider).board;
      for (int r = 0; r < 12; r++) {
        for (int c = 0; c < 12; c++) {
          if (board.cells[r][c].state == CellState.hidden) {
            final before = container.read(gameControllerProvider).minesLeft;
            notifier.toggleFlag(r, c);
            final after = container.read(gameControllerProvider).minesLeft;
            expect(after, before - 1);
            return;
          }
        }
      }
    });

    test('unflagging restores minesLeft', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameControllerProvider.notifier);
      notifier.reveal(5, 5);

      // Find a hidden cell (flood fill may have revealed some cells)
      final board = container.read(gameControllerProvider).board;
      int? fr, fc;
      outer:
      for (int r = 0; r < 12; r++) {
        for (int c = 0; c < 12; c++) {
          if (board.cells[r][c].state == CellState.hidden) {
            fr = r;
            fc = c;
            break outer;
          }
        }
      }
      if (fr == null || fc == null) return; // All cells revealed — win, skip

      final before = container.read(gameControllerProvider).minesLeft;
      notifier.toggleFlag(fr, fc);
      final afterFlag = container.read(gameControllerProvider).minesLeft;
      expect(afterFlag, before - 1);
      notifier.toggleFlag(fr, fc);
      final afterUnflag = container.read(gameControllerProvider).minesLeft;
      expect(afterUnflag, before);
    });

    test('cannot flag in idle state — but does not crash', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      // toggleFlag is allowed in idle per pre-project spec
      expect(
          () => container
              .read(gameControllerProvider.notifier)
              .toggleFlag(0, 0),
          returnsNormally);
    });

    test('cannot flag when game is lost', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameControllerProvider.notifier);
      notifier.reveal(5, 5);
      _forceGameLost(container, notifier);
      final before = container.read(gameControllerProvider).minesLeft;
      notifier.toggleFlag(2, 2);
      expect(container.read(gameControllerProvider).minesLeft, before);
    });
  });

  // ---------------------------------------------------------------------------
  // Loss (mine hit)
  // ---------------------------------------------------------------------------
  group('Loss detection', () {
    test('hitting a mine sets status to lost', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameControllerProvider.notifier);
      notifier.reveal(5, 5);
      _forceGameLost(container, notifier);
      expect(container.read(gameControllerProvider).status, GameStatus.lost);
    });

    test('all mines are revealed after loss', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameControllerProvider.notifier);
      notifier.reveal(5, 5);
      _forceGameLost(container, notifier);
      final board = container.read(gameControllerProvider).board;
      for (int r = 0; r < 12; r++) {
        for (int c = 0; c < 12; c++) {
          if (board.cells[r][c].isMine) {
            expect(board.cells[r][c].state, CellState.revealed,
                reason: 'mine [$r][$c] should be revealed after loss');
          }
        }
      }
    });

    test('shutdown service is called on loss', () {
      final tracker = _TrackingShutdownService();
      final container = _makeContainer(shutdownService: tracker);
      addTearDown(container.dispose);
      final notifier = container.read(gameControllerProvider.notifier);
      notifier.reveal(5, 5);
      _forceGameLost(container, notifier);
      expect(tracker.wasShutdownCalled, true);
    });

    test('reveals after loss are ignored', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameControllerProvider.notifier);
      notifier.reveal(5, 5);
      _forceGameLost(container, notifier);
      expect(
          () => notifier.reveal(11, 11), returnsNormally);
      expect(container.read(gameControllerProvider).status, GameStatus.lost);
    });
  });

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------
  group('Reset', () {
    test('resets to idle with 0 seconds and 20 mines', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameControllerProvider.notifier);
      notifier.reveal(5, 5);
      notifier.reset();
      final state = container.read(gameControllerProvider);
      expect(state.status, GameStatus.idle);
      expect(state.elapsedSeconds, 0);
      expect(state.minesLeft, 20);
      expect(state.board.minesPlaced, false);
    });

    test('can start a new game after reset', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gameControllerProvider.notifier);
      notifier.reveal(5, 5);
      notifier.reset();
      notifier.reveal(6, 6);
      expect(container.read(gameControllerProvider).status, GameStatus.playing);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Finds the first mine on the board (after mines are placed) and reveals it.
void _forceGameLost(
    ProviderContainer container, GameController notifier) {
  final board = container.read(gameControllerProvider).board;
  for (int r = 0; r < 12; r++) {
    for (int c = 0; c < 12; c++) {
      if (board.cells[r][c].isMine) {
        notifier.reveal(r, c);
        return;
      }
    }
  }
}
