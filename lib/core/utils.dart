String formatTime(int totalSeconds) {
  final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final secs = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$mins:$secs';
}
