/// Pure formatting helpers shared across the UI.

String formatDuration(Duration? duration) {
  if (duration == null || duration == Duration.zero) return '';
  String two(int n) => n.toString().padLeft(2, '0');
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return hours > 0
      ? '$hours:${two(minutes)}:${two(seconds)}'
      : '$minutes:${two(seconds)}';
}

String formatCount(int count) {
  String trim(double v) => v.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
  if (count >= 1000000000) return '${trim(count / 1e9)}B';
  if (count >= 1000000) return '${trim(count / 1e6)}M';
  if (count >= 1000) return '${trim(count / 1e3)}K';
  return '$count';
}

String formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
}

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 365) return '${diff.inDays ~/ 365} years ago';
  if (diff.inDays >= 30) return '${diff.inDays ~/ 30} months ago';
  if (diff.inDays >= 1) return '${diff.inDays} days ago';
  if (diff.inHours >= 1) return '${diff.inHours} hours ago';
  return 'Just now';
}

/// Makes a video title safe to use as a file name.
String sanitizeFileName(String name) {
  final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\r\n\t]'), '_').trim();
  final limited = cleaned.length > 120 ? cleaned.substring(0, 120) : cleaned;
  return limited.isEmpty ? 'video' : limited;
}
