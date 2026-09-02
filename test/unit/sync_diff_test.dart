// Sync Diff 单元测试（PRD §29 增量同步）。
import 'package:flutter_test/flutter_test.dart';
import 'package:sgphotowall/data/db/app_database.dart';
import 'package:sgphotowall/data/provider/provider_models.dart';
import 'package:sgphotowall/data/sync/sync_diff.dart';

MediaItem _localItem({
  required String remoteFileId,
  int sizeBytes = 100,
  DateTime? modifiedTime,
  String? remoteVersion = 'v1',
  String? checksum = 'c1',
}) => MediaItem(
  id: remoteFileId.hashCode & 0x7fffffff,
  providerAccountId: 1,
  providerType: ProviderType.cloud115.wireName,
  accountKey: 'acc-1',
  remoteFileId: remoteFileId,
  parentRemoteFolderId: 'folder-1',
  name: '$remoteFileId.jpg',
  mediaType: 'IMAGE',
  mimeType: 'image/jpeg',
  sizeBytes: sizeBytes,
  captureTime: DateTime(2025, 1, 1),
  modifiedTime: modifiedTime ?? DateTime(2025, 1, 2),
  remoteVersion: remoteVersion,
  checksum: checksum,
  width: 100,
  height: 100,
  durationMs: null,
  containerFormat: null,
  videoCodec: null,
  audioCodec: null,
  originalMimeType: null,
  previewPath: null,
  status: MediaStatus.active,
  createdAt: DateTime(2025, 1, 3),
  updatedAt: DateTime(2025, 1, 3),
);

RemoteMedia _remoteItem(
  String remoteFileId, {
  int sizeBytes = 100,
  DateTime? modifiedTime,
  String? remoteVersion = 'v1',
  String? checksum = 'c1',
}) => RemoteMedia(
  remoteFileId: remoteFileId,
  parentFolderId: 'folder-1',
  name: '$remoteFileId.jpg',
  mediaType: MediaType.image,
  mimeType: 'image/jpeg',
  sizeBytes: sizeBytes,
  captureTime: DateTime(2025, 1, 1),
  modifiedTime: modifiedTime ?? DateTime(2025, 1, 2),
  remoteVersion: remoteVersion,
  checksum: checksum,
  width: 100,
  height: 100,
);

void main() {
  group('diffMedia', () {
    test('新增：远端存在本地不存在 → added', () {
      final result = diffMedia(remote: [_remoteItem('a')], local: const []);
      expect(result.added, hasLength(1));
      expect(result.updated, isEmpty);
      expect(result.deleted, isEmpty);
      expect(result.unchanged, isEmpty);
      expect(result.remoteTotal, 1);
    });

    test('删除：本地存在远端不存在 → deleted', () {
      final result = diffMedia(
        remote: [],
        local: [_localItem(remoteFileId: 'a')],
      );
      expect(result.deleted, hasLength(1));
      expect(result.deleted.first.remoteFileId, 'a');
    });

    test('未变化：版本/大小/修改时间/校验和一致 → unchanged', () {
      final result = diffMedia(
        remote: [_remoteItem('a')],
        local: [_localItem(remoteFileId: 'a')],
      );
      expect(result.unchanged, hasLength(1));
      expect(result.added, isEmpty);
      expect(result.updated, isEmpty);
      expect(result.deleted, isEmpty);
    });

    test('更新：remoteVersion 变化 → updated', () {
      final result = diffMedia(
        remote: [_remoteItem('a', remoteVersion: 'v2')],
        local: [_localItem(remoteFileId: 'a')],
      );
      expect(result.updated, hasLength(1));
    });

    test('更新：sizeBytes 变化 → updated', () {
      final result = diffMedia(
        remote: [_remoteItem('a', sizeBytes: 999)],
        local: [_localItem(remoteFileId: 'a')],
      );
      expect(result.updated, hasLength(1));
    });

    test('更新：modifiedTime 变化 → updated', () {
      final result = diffMedia(
        remote: [_remoteItem('a', modifiedTime: DateTime(2025, 6, 1))],
        local: [_localItem(remoteFileId: 'a')],
      );
      expect(result.updated, hasLength(1));
    });

    test('更新：checksum 变化 → updated', () {
      final result = diffMedia(
        remote: [_remoteItem('a', checksum: 'c2')],
        local: [_localItem(remoteFileId: 'a')],
      );
      expect(result.updated, hasLength(1));
    });

    test('远端 version 为 null 时不依据 version 判断（回退 size/mtime）', () {
      final result = diffMedia(
        remote: [_remoteItem('a', remoteVersion: null)],
        local: [_localItem(remoteFileId: 'a', remoteVersion: 'v1')],
      );
      expect(result.unchanged, hasLength(1));
    });

    test('混合场景：新增 + 更新 + 删除 + 不变', () {
      final result = diffMedia(
        remote: [
          _remoteItem('keep'),
          _remoteItem('changed', sizeBytes: 200),
          _remoteItem('new'),
        ],
        local: [
          _localItem(remoteFileId: 'keep'),
          _localItem(remoteFileId: 'changed'),
          _localItem(remoteFileId: 'gone'),
        ],
      );
      expect(result.added.map((m) => m.remoteFileId), ['new']);
      expect(result.updated.map((m) => m.remoteFileId), ['changed']);
      expect(result.deleted.map((m) => m.remoteFileId), ['gone']);
      expect(result.unchanged.map((m) => m.remoteFileId), ['keep']);
      expect(result.remoteTotal, 3);
    });
  });
}
