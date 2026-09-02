import 'dart:async';

import '../data/db/app_database.dart';
import '../data/sync/sync_engine.dart';

/// 同步服务：防重入 + 进度流转发（PRD §10.1）。
class SyncService {
  SyncService(this._engine);

  final SyncEngine _engine;
  final _progressController = StreamController<SyncProgress>.broadcast();
  Future<SyncOutcome>? _running;

  Stream<SyncProgress> get progress => _progressController.stream;

  bool get isRunning => _running != null;

  /// 触发同步；已有同步进行中时直接返回进行中的 Future。
  Future<SyncOutcome> sync({
    SyncTrigger trigger = SyncTrigger.manual,
    int? providerAccountId,
  }) {
    final existing = _running;
    if (existing != null) return existing;

    final future = _run(trigger, providerAccountId);
    _running = future;
    return future;
  }

  Future<SyncOutcome> _run(SyncTrigger trigger, int? providerAccountId) async {
    final sub = _engine.progress.listen(_progressController.add);
    try {
      return await _engine.syncAll(
        trigger: trigger,
        providerAccountId: providerAccountId,
      );
    } finally {
      await sub.cancel();
      _running = null;
    }
  }

  void dispose() {
    _progressController.close();
    _engine.dispose();
  }
}
