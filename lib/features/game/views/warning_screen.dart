import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';

class WarningScreen extends StatefulWidget {
  const WarningScreen({super.key});

  @override
  State<WarningScreen> createState() => _WarningScreenState();
}

class _WarningScreenState extends State<WarningScreen> {
  bool _understood = false;

  void _accept() {
    Navigator.pushReplacementNamed(context, '/game');
  }

  void _cancel() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '\u26A0\uFE0F',
                  style: TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 24),
                Text(
                  'CAMPO MINADO',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warning,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'com Desligamento Automático',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withAlpha(30),
                    border: Border.all(color: AppTheme.danger, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppTheme.danger, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'AVISO REAL',
                            style: GoogleFonts.shareTechMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.danger,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Este jogo irá DESLIGAR O SEU COMPUTADOR '
                        'caso você clique em uma mina.',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Salve todos os arquivos antes de jogar.\n'
                        '• O desligamento é real e imediato.\n'
                        '• Grade 12×12 com 20 minas.\n'
                        '• Primeiro clique é sempre seguro.',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => setState(() => _understood = !_understood),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _understood,
                        onChanged: (v) =>
                            setState(() => _understood = v ?? false),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Entendo as consequências',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: _cancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppTheme.textSecondary, width: 1.5),
                        foregroundColor: AppTheme.textSecondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        textStyle: GoogleFonts.shareTechMono(
                            fontSize: 14, letterSpacing: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _understood ? _accept : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _understood
                            ? AppTheme.danger
                            : AppTheme.cellHidden,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.cellHidden,
                        disabledForegroundColor:
                            AppTheme.textSecondary.withAlpha(100),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        textStyle: GoogleFonts.shareTechMono(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Aceitar e Jogar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
