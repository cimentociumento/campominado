import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/constants.dart';
import '../controllers/game_controller.dart';
import '../widgets/board_widget.dart';
import '../widgets/hud_widget.dart';

const int _kShutdownCountdown = 8;

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? _countdown;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = _kShutdownCountdown);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown != null && _countdown! > 0) {
          _countdown = _countdown! - 1;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GameState>(gameControllerProvider, (prev, next) {
      if (prev?.status != GameStatus.lost &&
          next.status == GameStatus.lost) {
        _startCountdown();
      }
      if (prev?.status != GameStatus.won && next.status == GameStatus.won) {
        Navigator.pushReplacementNamed(context, '/win');
      }
    });

    final gameState = ref.watch(gameControllerProvider);
    final isLost = gameState.status == GameStatus.lost;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          const HudWidget(),
          Expanded(
            child: Stack(
              children: [
                const _BoardArea(),
                if (isLost) _LostOverlay(countdown: _countdown ?? _kShutdownCountdown),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardArea extends StatelessWidget {
  const _BoardArea();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _GameHint(),
            SizedBox(height: 8),
            Expanded(
              child: Center(child: BoardWidget()),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameHint extends ConsumerWidget {
  const _GameHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(gameControllerProvider.select((s) => s.status));
    final label = switch (status) {
      GameStatus.idle ||
      GameStatus.playing =>
        'Clique para revelar  |  Clique direito para bandeira',
      GameStatus.won => '\u{1F3C6}  Parabéns! Você venceu!',
      GameStatus.lost => '\u{1F4A5}  BOOM! Você pisou em uma mina!',
    };
    return Text(
      label,
      style: GoogleFonts.shareTechMono(
        fontSize: 12,
        color: switch (status) {
          GameStatus.won => const Color(0xFF69F0AE),
          GameStatus.lost => AppTheme.danger,
          _ => AppTheme.textSecondary,
        },
        letterSpacing: 1,
      ),
    );
  }
}

class _LostOverlay extends StatelessWidget {
  final int countdown;

  const _LostOverlay({required this.countdown});

  @override
  Widget build(BuildContext context) {
    final isDone = countdown <= 0;

    return Container(
      color: Colors.black.withAlpha(190),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.danger.withAlpha(235),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.danger, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.danger.withAlpha(120),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDone ? '\u{1F480}' : '\u{1F4A5}',
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                'GAME OVER',
                style: GoogleFonts.shareTechMono(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 16),
              if (isDone) ...[
                Text(
                  kUseRealShutdown ? 'PC DESLIGANDO...' : '[MOCK] SIMULADO',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ] else ...[
                Text(
                  kUseRealShutdown
                      ? 'PC desligando em:'
                      : '[MODO DEV] Shutdown simulado em:',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$countdown',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: countdown <= 3
                        ? Colors.white
                        : Colors.white.withAlpha(210),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'segundo${countdown == 1 ? '' : 's'}',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 14,
                    color: Colors.white60,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
