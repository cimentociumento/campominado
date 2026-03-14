import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/utils.dart';
import '../controllers/game_controller.dart';

class HudWidget extends ConsumerWidget {
  const HudWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final notifier = ref.read(gameControllerProvider.notifier);

    final emoji = switch (gameState.status) {
      GameStatus.won => '\u{1F60E}',
      GameStatus.lost => '\u{1F635}',
      _ => '\u{1F60A}',
    };

    return Container(
      height: 60,
      color: AppTheme.hudBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _HudSection(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('\u{1F4A3}', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  gameState.minesLeft.toString().padLeft(3, '0'),
                  style: GoogleFonts.shareTechMono(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF5252),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: notifier.reset,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.cellHidden,
                    border: Border.all(
                        color: AppTheme.cellHiddenBorder, width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38,
                          offset: Offset(1, 2),
                          blurRadius: 3)
                    ],
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ),
          ),
          _HudSection(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('\u23F1', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  formatTime(gameState.elapsedSeconds),
                  style: GoogleFonts.shareTechMono(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF69F0AE),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HudSection extends StatelessWidget {
  final Widget child;

  const _HudSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: child,
    );
  }
}
