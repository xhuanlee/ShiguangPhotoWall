// Drift 数据库 + DAO 集成测试（内存数据库，PRD §13 / §24 / §55-16）。
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sgphotowall/data/db/app_database.dart';
import 'package:sgphotowall/data/preview/preview_store.dart';
import 'package:sgphotowall/data/sync/preview_gc.dart';

void main() {
  late AppDatabase db;
  late AppDao dao;

  setUp(() {
    db = AppDatabase.memory();
    dao = db.appDao;
  });

  tearDown(() async {
    await db.close();
  });

  MediaItemsCompanion media({
    required String remoteFileId,
    int providerAccountId = 1,
    String providerType = '115_CLOUD',
    String accountKey = 'acc-1',
    String? previewPath,
    int sizeBytes = 100,
    String mediaType = 'IMAGE',
    String? remoteVersion = 'v1',
  }) => MediaItemsCompanion.insert(
    providerAccountId: providerAccountId,
    providerType: providerType,
    accountKey: accountKey,
    remoteFileId: remoteFileId,
    name: '$remoteFileId.jpg',
    mediaType: mediaType,
    mimeType: 'image/jpeg',
    sizeBytes: sizeBytes,
    modifiedTime: DateTime(2025, 1, 2),
    remoteVersion: Value(remoteVersion),
    previewPath: Value(previewPath),
    createdAt: DateTime(2025, 1, 3),
    updatedAt: DateTime(2025, 1, 3),
  );

  group('ProviderAccounts / Credentials', () {
    test('账号 upsert：同 providerType+accountId 唯一', () async {
      final id = await dao.upsertAccount(
        ProviderAccountsCompanion.insert(
          providerType: '115_CLOUD',
          accountId: 'user-1',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      );
      expect(id, greaterThan(0));

      await dao.upsertCredential(
        CredentialsCompanion.insert(
          providerAccountId: Value(id),
          accessTokenEncrypted: 'enc-token',
          expiresAt: DateTime(2099, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      );

      final credential = await dao.getCredential(id);
      expect(credential, isNotNull);
      expect(credential!.accessTokenEncrypted, 'enc-token');

      // 更新覆盖。
      await dao.upsertCredential(
        CredentialsCompanion.insert(
          providerAccountId: Value(id),
          accessTokenEncrypted: 'enc-token-v2',
          expiresAt: DateTime(2099, 1, 1),
          updatedAt: DateTime(2025, 1, 2),
        ),
      );
      expect(
        (await dao.getCredential(id))!.accessTokenEncrypted,
        'enc-token-v2',
      );

      await dao.deleteCredential(id);
      expect(await dao.getCredential(id), isNull);
    });

    test('账号状态更新与删除', () async {
      final id = await dao.upsertAccount(
        ProviderAccountsCompanion.insert(
          providerType: 'TIANYI_CLOUD',
          accountId: 'user-2',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      );

      await dao.updateAccountStatus(
        id,
        status: AccountStatus.needReauth,
        lastSyncError: 'token expired',
      );

      final account = await dao.findAccountByType('TIANYI_CLOUD');
      expect(account!.status, AccountStatus.needReauth);
      expect(account.lastSyncError, 'token expired');

      await dao.deleteAccount(id);
      expect(await dao.findAccountByType('TIANYI_CLOUD'), isNull);
    });
  });

  group('FolderConfigs', () {
    test('replaceFolders 具备替换语义', () async {
      final id = await dao.upsertAccount(
        ProviderAccountsCompanion.insert(
          providerType: '115_CLOUD',
          accountId: 'user-1',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      );

      Future<void> seed(List<String> folderIds) => dao.replaceFolders(id, [
        for (final f in folderIds)
          FolderConfigsCompanion.insert(
            providerAccountId: id,
            remoteFolderId: f,
            folderPathSnapshot: '/$f',
            folderName: f,
            createdAt: DateTime(2025, 1, 1),
            updatedAt: DateTime(2025, 1, 1),
          ),
      ]);

      await seed(['f1', 'f2']);
      expect((await dao.getFolders(id)).map((f) => f.remoteFolderId), [
        'f1',
        'f2',
      ]);

      // 替换：旧配置全部移除。
      await seed(['f3']);
      expect((await dao.getFolders(id)).map((f) => f.remoteFolderId), ['f3']);
    });

    test('markFolderStatus 标记远端缺失', () async {
      final id = await dao.upsertAccount(
        ProviderAccountsCompanion.insert(
          providerType: '115_CLOUD',
          accountId: 'user-1',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      );
      await dao.replaceFolders(id, [
        FolderConfigsCompanion.insert(
          providerAccountId: id,
          remoteFolderId: 'f1',
          folderPathSnapshot: '/f1',
          folderName: 'f1',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      ]);

      await dao.markFolderStatus('f1', FolderConfigStatus.remoteMissing);

      final folders = await dao.getFolders(id);
      expect(folders.first.status, FolderConfigStatus.remoteMissing);
    });
  });

  group('MediaItems', () {
    test('批量 upsert 幂等：重复执行不产生重复行且更新字段', () async {
      await dao.upsertAccount(
        ProviderAccountsCompanion.insert(
          providerType: '115_CLOUD',
          accountId: 'user-1',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        ),
      );

      await dao.upsertMediaBatch([
        media(remoteFileId: 'a', sizeBytes: 100),
        media(remoteFileId: 'b', sizeBytes: 200),
      ]);
      await dao.upsertMediaBatch([
        media(remoteFileId: 'a', sizeBytes: 300), // 更新
        media(remoteFileId: 'c', sizeBytes: 400), // 新增
      ]);

      final page = await dao.getMediaPage(limit: 100, offset: 0);
      expect(page, hasLength(3));

      final a = page.firstWhere((m) => m.remoteFileId == 'a');
      expect(a.sizeBytes, 300);
    });

    test('分页查询按拍摄时间倒序 + mediaType 过滤', () async {
      await dao.upsertMediaBatch([
        media(remoteFileId: 'old', previewPath: 'old.webp'),
        media(remoteFileId: 'new', mediaType: 'VIDEO'),
      ]);
      // old 无 captureTime（null）→ 按 modifiedTime 排序。

      final images = await dao.getMediaPage(
        mediaType: 'IMAGE',
        limit: 10,
        offset: 0,
      );
      final videos = await dao.getMediaPage(
        mediaType: 'VIDEO',
        limit: 10,
        offset: 0,
      );

      expect(images, hasLength(1));
      expect(videos, hasLength(1));
      expect(videos.first.mediaType, 'VIDEO');

      final page1 = await dao.getMediaPage(limit: 1, offset: 0);
      final page2 = await dao.getMediaPage(limit: 1, offset: 1);
      expect(page1, hasLength(1));
      expect(page2, hasLength(1));
      expect(page1.first.remoteFileId, isNot(equals(page2.first.remoteFileId)));
    });

    test('markMediaStatus 后 active 查询排除 deleted', () async {
      await dao.upsertMediaBatch([
        media(remoteFileId: 'keep', previewPath: 'keep.webp'),
        media(remoteFileId: 'drop', previewPath: 'drop.webp'),
      ]);

      final all = await dao.getMediaPage(limit: 100, offset: 0);
      final dropId = all.firstWhere((m) => m.remoteFileId == 'drop').id;
      await dao.markMediaStatus([dropId], MediaStatus.deleted);

      final active = await dao.getMediaPage(limit: 100, offset: 0);
      expect(active.map((m) => m.remoteFileId), ['keep']);

      // activePreviewPaths 只包含 active 行。
      final paths = await dao.activePreviewPaths();
      expect(paths, {'keep.webp'});
    });

    test('countMedia 计数', () async {
      await dao.upsertMediaBatch([
        media(remoteFileId: 'i1'),
        media(remoteFileId: 'v1', mediaType: 'VIDEO'),
      ]);
      expect(await dao.countMedia(), 2);
      expect(await dao.countMedia(mediaType: 'IMAGE'), 1);
      expect(await dao.countMedia(mediaType: 'VIDEO'), 1);
    });
  });

  group('SyncRuns', () {
    test('开始 / 完成 / 查询最近一次', () async {
      final runId = await dao.startSyncRun(SyncTrigger.manual);
      final running = await dao.watchLatestSyncRun().first;
      expect(running!.status, SyncRunStatus.running);

      await dao.finishSyncRun(
        runId,
        status: SyncRunStatus.success,
        foundCount: 10,
        addedCount: 5,
        updatedCount: 3,
        deletedCount: 2,
      );

      final finished = await dao.watchLatestSyncRun().first;
      expect(finished!.status, SyncRunStatus.success);
      expect(finished.foundCount, 10);
      expect(finished.addedCount, 5);
      expect(finished.finishedAt, isNotNull);
    });
  });

  group('PairingSessions', () {
    test('插入 / 查询 / 标记使用 / 过期清理', () async {
      await dao.insertPairingSession(
        PairingSessionsCompanion.insert(
          sessionId: 's1',
          nonce: 'n1',
          tvPublicKey: 'pub',
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        ),
      );

      final session = await dao.getPairingSession('s1');
      expect(session, isNotNull);
      expect(session!.usedAt, isNull);

      await dao.markPairingSessionUsed('s1');
      expect((await dao.getPairingSession('s1'))!.usedAt, isNotNull);

      await dao.deleteExpiredPairingSessions();
      expect(await dao.getPairingSession('s1'), isNotNull); // 未过期不删

      // 插入已过期会话并清理。
      await dao.insertPairingSession(
        PairingSessionsCompanion.insert(
          sessionId: 's2',
          nonce: 'n2',
          tvPublicKey: 'pub',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      );
      await dao.deleteExpiredPairingSessions();
      expect(await dao.getPairingSession('s2'), isNull);
    });
  });

  group('PreviewGarbageCollector', () {
    test('仅删除孤儿 preview，保留 active 媒体的 preview', () async {
      final dir = await Directory.systemTemp.createTemp('preview_gc_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final store = PreviewStore(dir);

      await dao.upsertMediaBatch([
        media(remoteFileId: 'keep', previewPath: 'keep.webp'),
      ]);

      // keep.webp 属于 active 媒体；orphan.webp 为孤儿。
      await store.write('keep.webp', [1, 2, 3]);
      await store.write('orphan.webp', [4, 5, 6]);

      final gc = PreviewGarbageCollector(dao: dao, store: store);
      final deleted = await gc.collect();

      expect(deleted, 1);
      expect(store.exists('keep.webp'), isTrue);
      expect(store.exists('orphan.webp'), isFalse);
    });

    test('active preview 修改后旧 preview 变为孤儿被回收', () async {
      final dir = await Directory.systemTemp.createTemp('preview_gc_test2');
      addTearDown(() => dir.deleteSync(recursive: true));
      final store = PreviewStore(dir);

      await dao.upsertMediaBatch([
        media(remoteFileId: 'a', previewPath: 'v1.webp'),
      ]);
      await store.write('v1.webp', [1]);

      // 同步更新 preview 指向新版本。
      final row = (await dao.getMediaPage(limit: 10, offset: 0)).first;
      await dao.updateMediaPreview(row.id, 'v2.webp');
      await store.write('v2.webp', [2]);

      final deleted = await PreviewGarbageCollector(
        dao: dao,
        store: store,
      ).collect();

      expect(deleted, 1);
      expect(store.exists('v1.webp'), isFalse);
      expect(store.exists('v2.webp'), isTrue);
    });
  });

  group('PreviewStore', () {
    test('relativeName 由 provider|account|remoteId|version|size 派生', () {
      final a = PreviewStore.relativeName(
        providerType: '115_CLOUD',
        accountKey: 'acc-1',
        remoteId: 'file-1',
        version: 'v1',
        size: 100,
      );
      final b = PreviewStore.relativeName(
        providerType: '115_CLOUD',
        accountKey: 'acc-1',
        remoteId: 'file-1',
        version: 'v2', // 版本变化 → 新文件名
        size: 100,
      );
      expect(a, isNot(equals(b)));
      expect(a.endsWith('.webp'), isTrue);
    });

    test('listAll 列出全部文件', () async {
      final dir = await Directory.systemTemp.createTemp('preview_store_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final store = PreviewStore(dir);

      await store.write('a.webp', [1]);
      await store.write('b.webp', [2]);

      expect(store.listAll().toSet(), {'a.webp', 'b.webp'});
    });
  });
}
