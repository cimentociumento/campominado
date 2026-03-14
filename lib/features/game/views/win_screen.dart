import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/utils.dart';
import '../controllers/game_controller.dart';

class WinScreen extends ConsumerWidget {
  const WinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final elapsed = formatTime(gameState.elapsedSeconds);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('\u{1F3C6}', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              'VITÓRIA!',
              style: GoogleFonts.shareTechMono(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF69F0AE),
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Você sobreviveu ao campo minado!',
              style: GoogleFonts.shareTechMono(
                fontSize: 16,
                color: AppTheme.textSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3460).withAlpha(180),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFF69F0AE).withAlpha(100), width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    'TEMPO',
                    style: GoogleFonts.shareTechMono(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    elapsed,
                    style: GoogleFonts.shareTechMono(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF69F0AE),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                ref.read(gameControllerProvider.notifier).reset();
                Navigator.pushReplacementNamed(context, '/game');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF69F0AE),
                foregroundColor: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 18),
                textStyle: GoogleFonts.shareTechMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Novo Jogo'),
            ),
          ],
        ),
      ),
    );
  }
}
