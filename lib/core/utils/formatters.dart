/// 时长格式化（缓存友好：纯函数 + 常见结果）。
String formatDuration(int durationMs) {
  if (durationMs <= 0) return '0:00';
  final totalSeconds = durationMs ~/ 1000;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

/// 文件大小格式化。
String formatBytes(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)}MB';
  }
  return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)}GB';
}

/// 日期展示（yyyy-MM-dd）。
String formatDisplayDate(DateTime? time) {
  if (time == null) return '';
  final local = time.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
