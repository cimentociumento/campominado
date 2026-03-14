import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF1A1A2E);
  static const Color hudBackground = Color(0xFF16213E);
  static const Color cellHidden = Color(0xFF2D2D44);
  static const Color cellHiddenBorder = Color(0xFF3D3D58);
  static const Color cellRevealed = Color(0xFFE8E8E8);
  static const Color cellRevealedBorder = Color(0xFFCCCCCC);
  static const Color cellMine = Color(0xFFC62828);
  static const Color cellFlag = Color(0xFF2D2D44);
  static const Color accent = Color(0xFF0F3460);
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color warning = Color(0xFFF57F17);
  static const Color danger = Color(0xFFB71C1C);

  static const Map<int, Color> numberColors = {
    1: Color(0xFF1565C0),
    2: Color(0xFF2E7D32),
    3: Color(0xFFC62828),
    4: Color(0xFF1A237E),
    5: Color(0xFF4E342E),
    6: Color(0xFF00838F),
    7: Color(0xFF212121),
    8: Color(0xFF757575),
  };

  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        surface: background,
        primary: const Color(0xFF0F3460),
        secondary: const Color(0xFF533483),
      ),
      textTheme: GoogleFonts.shareTechMonoTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF533483);
          }
          return const Color(0xFF2D2D44);
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFF9E9E9E), width: 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.shareTechMono(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}
