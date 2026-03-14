import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../models/cell.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final VoidCallback? onReveal;
  final VoidCallback? onFlag;
  final double size;
  final bool isDetonated;

  const CellWidget({
    super.key,
    required this.cell,
    required this.size,
    this.onReveal,
    this.onFlag,
    this.isDetonated = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReveal,
      onSecondaryTap: onFlag,
      child: Container(
        width: size,
        height: size,
        decoration: _decoration(),
        child: Center(child: _content()),
      ),
    );
  }

  BoxDecoration _decoration() {
    if (cell.state == CellState.revealed) {
      if (cell.isMine) {
        return BoxDecoration(
          color: isDetonated
              ? AppTheme.cellMine.withAlpha(230)
              : AppTheme.cellMine.withAlpha(180),
          border: Border.all(
              color: AppTheme.cellMine.withAlpha(255), width: 0.5),
        );
      }
      return BoxDecoration(
        color: AppTheme.cellRevealed,
        border: Border.all(color: AppTheme.cellRevealedBorder, width: 0.5),
      );
    }
    return BoxDecoration(
      color: AppTheme.cellHidden,
      border: Border.all(color: AppTheme.cellHiddenBorder, width: 0.5),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    );
  }

  Widget? _content() {
    final fontSize = (size * 0.45).clamp(12.0, 28.0);

    switch (cell.state) {
      case CellState.flagged:
        return Text(
          '\u{1F6A9}',
          style: TextStyle(fontSize: fontSize),
        );

      case CellState.revealed:
        if (cell.isMine) {
          return Text(
            '\u{1F4A3}',
            style: TextStyle(fontSize: fontSize),
          );
        }
        if (cell.adjacentMines > 0) {
          return Text(
            '${cell.adjacentMines}',
            style: GoogleFonts.shareTechMono(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.numberColors[cell.adjacentMines] ??
                  AppTheme.textPrimary,
            ),
          );
        }
        return null;

      case CellState.hidden:
        return null;
    }
  }
}
