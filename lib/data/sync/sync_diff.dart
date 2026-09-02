import '../db/app_database.dart';
import '../provider/provider_models.dart';

/// 同步 Diff 结果（PRD §29）。
class SyncDiffResult {
  const SyncDiffResult({
    required this.added,
    required this.updated,
    required this.deleted,
    required this.unchanged,
  });

  final List<RemoteMedia> added;
  final List<RemoteMedia> updated;

  /// 本地存在但远端不存在的行（删除 / 移出同步范围）。
  final List<MediaItem> deleted;
  final List<RemoteMedia> unchanged;

  int get remoteTotal => added.length + updated.length + unchanged.length;
}

/// 唯一键：providerType + accountId + remoteFileId。
/// 版本判断：remoteVersion / size / modifiedTime / checksum 任意变化 → updated。
SyncDiffResult diffMedia({
  required List<RemoteMedia> remote,
  required List<MediaItem> local,
}) {
  final localByRemoteId = {for (final row in local) row.remoteFileId: row};
  final remoteIds = remote.map((m) => m.remoteFileId).toSet();

  final added = <RemoteMedia>[];
  final updated = <RemoteMedia>[];
  final unchanged = <RemoteMedia>[];

  for (final r in remote) {
    final existing = localByRemoteId[r.remoteFileId];
    if (existing == null) {
      added.add(r);
    } else if (isChanged(existing, r)) {
      updated.add(r);
    } else {
      unchanged.add(r);
    }
  }

  final deleted = local
      .where((row) => !remoteIds.contains(row.remoteFileId))
      .toList();

  return SyncDiffResult(
    added: added,
    updated: updated,
    deleted: deleted,
    unchanged: unchanged,
  );
}

@pragma('vm:prefer-inline')
bool isChanged(MediaItem local, RemoteMedia remote) {
  final localVersion = local.remoteVersion;
  final remoteVersion = remote.remoteVersion;
  if (localVersion != null &&
      remoteVersion != null &&
      localVersion != remoteVersion) {
    return true;
  }
  if (local.sizeBytes != remote.sizeBytes) return true;
  if (local.modifiedTime != remote.modifiedTime) return true;
  final localChecksum = local.checksum;
  final remoteChecksum = remote.checksum;
  if (localChecksum != null &&
      remoteChecksum != null &&
      localChecksum != remoteChecksum) {
    return true;
  }
  return false;
}
