/// 统一媒体排序：captureTime DESC → remoteModifiedTime DESC → createdTime DESC。
///
/// PRD §5.1：所有列表按此排序，时间缺失时逐级 fallback。
int compareMediaDesc(MediaSortable a, MediaSortable b) {
  final at = a.effectiveSortTime;
  final bt = b.effectiveSortTime;
  if (at != null && bt != null) {
    final c = bt.compareTo(at);
    if (c != 0) return c;
  } else if (at != null) {
    return -1;
  } else if (bt != null) {
    return 1;
  }
  // createdTime fallback
  final bc = b.createdTime.compareTo(a.createdTime);
  if (bc != 0) return bc;
  // 稳定兜底：remoteFileId
  return b.remoteFileId.compareTo(a.remoteFileId);
}

/// 排序所需最小字段集。
abstract class MediaSortable {
  DateTime? get captureTime;
  DateTime get modifiedTime;
  DateTime get createdTime;
  String get remoteFileId;

  /// captureTime → modifiedTime → createdTime
  DateTime? get effectiveSortTime => captureTime ?? modifiedTime;
}
