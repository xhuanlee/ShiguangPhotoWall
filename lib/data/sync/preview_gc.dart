import '../db/app_database.dart';
import '../preview/preview_store.dart';

/// Preview GC（PRD Phase E / §30）：
/// 只删除不属于任何 active media 的 preview（orphan）。
///
/// 强制规则：
/// - 不得全量删除后重建
/// - 刷新失败时不得清理（由 SyncEngine 控制调用时机）
class PreviewGarbageCollector {
  PreviewGarbageCollector({required this.dao, required this.store});

  final AppDao dao;
  final PreviewStore store;

  /// 返回删除数量。
  Future<int> collect() async {
    final active = await dao.activePreviewPaths();
    var deleted = 0;
    for (final relative in store.listAll()) {
      if (!active.contains(relative)) {
        await store.delete(relative);
        deleted++;
      }
    }
    return deleted;
  }
}
