import 'dart:async';

import 'package:drift/drift.dart' show Value;

import '../../core/error/network_error.dart';
import '../crypto/token_cipher.dart';
import '../db/app_database.dart' hide Credentials;
import '../preview/preview_manager.dart';
import '../preview/preview_store.dart';
import '../provider/base_rest_provider.dart';
import '../provider/provider_models.dart';
import '../provider/provider_registry.dart';
import 'preview_gc.dart';
import 'sync_diff.dart';

/// 同步状态可视化（PRD §10.1）。
enum SyncPhase {
  idle,
  connecting,
  fetchingDirs,
  syncingMedia,
  generatingPreviews,
  cleaningPreviews,
  success,
  partialFailure,
  authFailed,
  networkFailed,
}

class SyncProgress {
  const SyncProgress({required this.phase, this.provider, this.detail});

  final SyncPhase phase;
  final ProviderType? provider;
  final String? detail;

  String get displayLabel => switch (phase) {
    SyncPhase.idle => '空闲',
    SyncPhase.connecting => '正在连接…',
    SyncPhase.fetchingDirs => '获取目录…',
    SyncPhase.syncingMedia => '同步媒体…',
    SyncPhase.generatingPreviews => '生成预览…',
    SyncPhase.cleaningPreviews => '清理旧预览…',
    SyncPhase.success => '刷新成功',
    SyncPhase.partialFailure => '部分失败',
    SyncPhase.authFailed => '认证失效',
    SyncPhase.networkFailed => '网络失败',
  };
}

/// 单账号同步结果。
class AccountSyncResult {
  const AccountSyncResult({
    required this.accountId,
    required this.type,
    required this.status,
    this.foundCount = 0,
    this.addedCount = 0,
    this.updatedCount = 0,
    this.deletedCount = 0,
    this.previewCreatedCount = 0,
    this.error,
  });

  final int accountId;
  final ProviderType type;
  final SyncRunStatus status;
  final int foundCount;
  final int addedCount;
  final int updatedCount;
  final int deletedCount;
  final int previewCreatedCount;
  final String? error;
}

/// 整体同步结果。
class SyncOutcome {
  const SyncOutcome({
    required this.status,
    required this.accounts,
    this.foundCount = 0,
    this.addedCount = 0,
    this.updatedCount = 0,
    this.deletedCount = 0,
    this.previewCreatedCount = 0,
    this.previewDeletedCount = 0,
    this.errorMessage,
  });

  final SyncRunStatus status;
  final List<AccountSyncResult> accounts;
  final int foundCount;
  final int addedCount;
  final int updatedCount;
  final int deletedCount;
  final int previewCreatedCount;
  final int previewDeletedCount;
  final String? errorMessage;

  bool get isSuccess => status == SyncRunStatus.success;
}

/// 同步引擎（PRD §11 Phase A-F）。
///
/// 核心原则：刷新失败时老数据可继续浏览、老 preview 不删除；
/// NEED_REAUTH 绝不删除 FolderConfig / MediaEntity / Preview。
class SyncEngine {
  SyncEngine({
    required this.dao,
    required this.registry,
    required this.cipher,
    required this.previewStore,
    required this.previewManager,
    required this.gc,
  });

  final AppDao dao;
  final ProviderRegistry registry;
  final TokenCipher cipher;
  final PreviewStore previewStore;
  final PreviewManager previewManager;
  final PreviewGarbageCollector gc;

  final _progressController = StreamController<SyncProgress>.broadcast();

  Stream<SyncProgress> get progress => _progressController.stream;

  void _emit(SyncPhase phase, {ProviderType? provider, String? detail}) {
    if (!_progressController.isClosed) {
      _progressController.add(
        SyncProgress(phase: phase, provider: provider, detail: detail),
      );
    }
  }

  /// 同步全部（或指定）Provider。
  Future<SyncOutcome> syncAll({
    SyncTrigger trigger = SyncTrigger.manual,
    int? providerAccountId,
  }) async {
    final runId = await dao.startSyncRun(trigger);
    _emit(SyncPhase.connecting);

    final accounts = (await dao.getAccounts())
        .where((a) => providerAccountId == null || a.id == providerAccountId)
        .toList();

    final results = <AccountSyncResult>[];

    for (final account in accounts) {
      final type = ProviderType.fromWire(account.providerType);
      if (type == null) continue;
      final result = await _syncAccount(account, type);
      results.add(result);
    }

    // Phase E：清理无用 Preview（仅在至少一个账号完全成功时）。
    var previewDeleted = 0;
    final anySuccess = results.any((r) => r.status == SyncRunStatus.success);
    if (anySuccess) {
      _emit(SyncPhase.cleaningPreviews);
      previewDeleted = await gc.collect();
    }

    final found = results.fold(0, (s, r) => s + r.foundCount);
    final added = results.fold(0, (s, r) => s + r.addedCount);
    final updated = results.fold(0, (s, r) => s + r.updatedCount);
    final deleted = results.fold(0, (s, r) => s + r.deletedCount);
    final previewCreated = results.fold(0, (s, r) => s + r.previewCreatedCount);
    final errorCount = results
        .where((r) => r.status != SyncRunStatus.success)
        .length;

    SyncRunStatus status;
    if (results.isEmpty || errorCount == 0) {
      status = SyncRunStatus.success;
    } else if (results.any((r) => r.status == SyncRunStatus.success)) {
      status = SyncRunStatus.partialFailure;
    } else {
      status = results.any((r) => r.status == SyncRunStatus.authFailed)
          ? SyncRunStatus.authFailed
          : SyncRunStatus.failed;
    }

    final errorMessage = results
        .where((r) => r.error != null)
        .map((r) => '${r.type.displayName}: ${r.error}')
        .join('; ');

    await dao.finishSyncRun(
      runId,
      status: status,
      foundCount: found,
      addedCount: added,
      updatedCount: updated,
      deletedCount: deleted,
      previewCreatedCount: previewCreated,
      previewDeletedCount: previewDeleted,
      errorCount: errorCount,
      errorMessage: errorMessage.isEmpty ? null : errorMessage,
    );

    _emit(switch (status) {
      SyncRunStatus.success => SyncPhase.success,
      SyncRunStatus.partialFailure => SyncPhase.partialFailure,
      SyncRunStatus.authFailed => SyncPhase.authFailed,
      _ => SyncPhase.networkFailed,
    });

    return SyncOutcome(
      status: status,
      accounts: results,
      foundCount: found,
      addedCount: added,
      updatedCount: updated,
      deletedCount: deleted,
      previewCreatedCount: previewCreated,
      previewDeletedCount: previewDeleted,
      errorMessage: errorMessage.isEmpty ? null : errorMessage,
    );
  }

  // ---- Phase A-F：单账号 --------------------------------------------------

  Future<AccountSyncResult> _syncAccount(
    ProviderAccount account,
    ProviderType type,
  ) async {
    final provider = registry.providerOf(type);
    final now = DateTime.now();

    // Phase A：加载配置 + 凭据状态。
    if (!provider.isConfigured) {
      return AccountSyncResult(
        accountId: account.id,
        type: type,
        status: SyncRunStatus.failed,
        error: 'Provider UNAVAILABLE（官方开放平台凭证未配置）',
      );
    }

    Credentials? credentials;
    try {
      final credRow = await dao.getCredential(account.id);
      if (credRow != null) {
        credentials = Credentials(
          accessToken: await cipher.decrypt(credRow.accessTokenEncrypted),
          refreshToken: credRow.refreshTokenEncrypted == null
              ? ''
              : await cipher.decrypt(credRow.refreshTokenEncrypted!),
          expiresAt: credRow.expiresAt,
          tokenType: credRow.tokenType,
          accountId: account.accountId,
        );
      }
    } catch (_) {
      credentials = null;
    }

    if (provider is BaseRestCloudProvider) {
      provider.applyCredentials(credentials);
    }

    final credentialState = credentials == null
        ? CredentialState.needReauth
        : await provider.validateCredential();

    if (credentialState != CredentialState.authenticated) {
      // NEED_REAUTH：跳过该 provider，不删除任何数据（PRD Phase A）。
      await dao.updateAccountStatus(
        account.id,
        status: AccountStatus.needReauth,
      );
      return AccountSyncResult(
        accountId: account.id,
        type: type,
        status: SyncRunStatus.authFailed,
        error: '认证已失效，需要重新认证',
      );
    }

    await dao.updateAccountStatus(account.id, status: AccountStatus.syncing);

    // Phase B：获取远端快照。
    _emit(SyncPhase.fetchingDirs, provider: type);
    final folders = (await dao.getFolders(account.id))
        .where((f) => f.enabled)
        .toList();
    if (folders.isEmpty) {
      await dao.updateAccountStatus(
        account.id,
        status: AccountStatus.authenticated,
        lastSyncAt: now,
      );
      return AccountSyncResult(
        accountId: account.id,
        type: type,
        status: SyncRunStatus.success,
      );
    }

    _emit(SyncPhase.syncingMedia, provider: type);
    final remote = <RemoteMedia>[];
    final succeededFolderIds = <String>{};
    final visited = <String>{};
    var folderError = false;
    var authExpired = false;
    final queue = List.of(folders);

    while (queue.isNotEmpty) {
      final folder = queue.removeAt(0);
      if (!visited.add(folder.remoteFolderId)) continue;

      var cursor = '0';
      while (true) {
        final pageResult = await provider.listMedia(
          folder.remoteFolderId,
          cursor,
        );
        if (pageResult.isErr) {
          final error = pageResult.fold(ok: (_) => null, err: (e) => e);
          if (error is Unauthorized) {
            authExpired = true;
          } else if (error is NotFound) {
            await dao.markFolderStatus(
              folder.remoteFolderId,
              FolderConfigStatus.remoteMissing,
            );
          } else {
            folderError = true;
          }
          break;
        }
        final page = pageResult.getOrThrow();
        remote.addAll(page.items);
        if (!page.hasMore) {
          succeededFolderIds.add(folder.remoteFolderId);
          break;
        }
        cursor = page.nextCursor!;
      }

      if (authExpired) break;

      // 递归子目录。
      if (folder.recursive) {
        final subResult = await provider.listFolders(folder.remoteFolderId);
        if (subResult.isOk) {
          for (final sub in subResult.getOrThrow()) {
            if (!visited.contains(sub.id)) {
              queue.add(
                FolderConfig(
                  id: -1,
                  providerAccountId: account.id,
                  remoteFolderId: sub.id,
                  folderPathSnapshot:
                      '${folder.folderPathSnapshot}/${sub.name}',
                  folderName: sub.name,
                  enabled: true,
                  recursive: true,
                  status: FolderConfigStatus.active,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
            }
          }
        } else {
          folderError = true;
        }
      }
    }

    if (authExpired) {
      await dao.updateAccountStatus(
        account.id,
        status: AccountStatus.needReauth,
      );
      return AccountSyncResult(
        accountId: account.id,
        type: type,
        status: SyncRunStatus.authFailed,
        error: '认证已失效，需要重新认证',
      );
    }

    // Phase C：Diff + Upsert（Phase F：事务提交）。
    final local = await dao.getMediaByProviderAccount(account.id);
    final diff = diffMedia(remote: remote, local: local);

    // 有目录级失败时不做删除判定（同步失败保留旧数据，PRD Case D）。
    final allowDeletion = !folderError;
    final toUpsert = [
      ...diff.added,
      ...diff.updated,
    ].map((m) => _toCompanion(m, account, now)).toList();
    final deletedIds = allowDeletion
        ? diff.deleted.map((row) => row.id).toList()
        : const <int>[];

    await dao.transaction(() async {
      if (toUpsert.isNotEmpty) {
        await dao.upsertMediaBatch(toUpsert);
      }
      if (deletedIds.isNotEmpty) {
        await dao.markMediaStatus(deletedIds, MediaStatus.deleted);
      }
    });

    // Phase D：生成/更新 Preview（并发受限）。
    _emit(SyncPhase.generatingPreviews, provider: type);
    var previewCreated = 0;
    final targets = [...diff.added, ...diff.updated];
    for (var i = 0; i < targets.length; i += previewManager.concurrency * 4) {
      final chunk = targets.skip(i).take(previewManager.concurrency * 4);
      final generated = await Future.wait(
        chunk.map(
          (m) => previewManager.generate(
            provider: provider,
            providerType: account.providerType,
            accountKey: account.accountId,
            media: m,
          ),
        ),
      );
      previewCreated += generated.whereType<String>().length;
    }

    await dao.updateAccountStatus(
      account.id,
      status: AccountStatus.authenticated,
      lastSyncAt: now,
    );

    return AccountSyncResult(
      accountId: account.id,
      type: type,
      status: folderError
          ? SyncRunStatus.partialFailure
          : SyncRunStatus.success,
      foundCount: diff.remoteTotal,
      addedCount: diff.added.length,
      updatedCount: diff.updated.length,
      deletedCount: deletedIds.length,
      previewCreatedCount: previewCreated,
      error: folderError ? '部分文件夹同步失败，旧数据已保留' : null,
    );
  }

  MediaItemsCompanion _toCompanion(
    RemoteMedia m,
    ProviderAccount account,
    DateTime now,
  ) {
    final previewRelative = PreviewStore.relativeName(
      providerType: account.providerType,
      accountKey: account.accountId,
      remoteId: m.remoteFileId,
      version: m.remoteVersion,
      size: m.sizeBytes,
    );
    return MediaItemsCompanion.insert(
      providerAccountId: account.id,
      providerType: account.providerType,
      accountKey: account.accountId,
      remoteFileId: m.remoteFileId,
      parentRemoteFolderId: Value(m.parentFolderId),
      name: m.name,
      mediaType: m.mediaType.wireName,
      mimeType: m.mimeType,
      sizeBytes: m.sizeBytes,
      captureTime: Value(m.captureTime),
      modifiedTime: m.modifiedTime,
      remoteVersion: Value(m.remoteVersion),
      checksum: Value(m.checksum),
      width: Value(m.width),
      height: Value(m.height),
      durationMs: Value(m.durationMs),
      status: Value(MediaStatus.active),
      previewPath: Value(previewRelative),
      createdAt: now,
      updatedAt: now,
    );
  }

  void dispose() {
    _progressController.close();
  }
}

/// 供 Pairing 接收配置后调用的 payload 落库（TV 端）。
Future<void> applyPairingPayload({
  required AppDao dao,
  required TokenCipher cipher,
  required Map<String, dynamic> payload,
}) async {
  final providers = payload['providers'] as List<dynamic>? ?? const [];
  for (final entry in providers) {
    final p = entry as Map<String, dynamic>;
    final typeWire = p['type'] as String?;
    final type = ProviderType.fromWire(typeWire);
    if (type == null) continue;

    final accountJson = p['account'] as Map<String, dynamic>? ?? {};
    final credentialJson = p['credential'] as Map<String, dynamic>? ?? {};
    final accountId = accountJson['accountId'] as String? ?? '';
    final displayName =
        accountJson['displayName'] as String? ?? type.displayName;

    // Upsert ProviderAccount（保留原账号关联）。
    final existingAccount = await dao.findAccountByType(type.wireName);
    final now = DateTime.now();
    final int accountIdValue;
    if (existingAccount == null) {
      accountIdValue = await dao.upsertAccount(
        ProviderAccountsCompanion.insert(
          providerType: type.wireName,
          accountId: accountId,
          displayName: Value(displayName),
          status: Value(AccountStatus.authenticated),
          createdAt: now,
          updatedAt: now,
          lastAuthenticatedAt: Value(now),
        ),
      );
    } else {
      accountIdValue = existingAccount.id;
      await dao.updateAccountStatus(
        existingAccount.id,
        status: AccountStatus.authenticated,
        lastAuthenticatedAt: now,
      );
    }

    // 覆盖 credential（AES-GCM 密文入库）。
    final accessToken = credentialJson['accessToken'] as String? ?? '';
    if (accessToken.isNotEmpty) {
      final refreshToken = credentialJson['refreshToken'] as String? ?? '';
      final expiresAt = credentialJson['expiresAt'] == null
          ? now.add(const Duration(hours: 1))
          : DateTime.tryParse(credentialJson['expiresAt'].toString()) ??
                now.add(const Duration(hours: 1));
      await dao.upsertCredential(
        CredentialsCompanion.insert(
          providerAccountId: Value(accountIdValue),
          accessTokenEncrypted: await cipher.encrypt(accessToken),
          refreshTokenEncrypted: Value(
            refreshToken.isEmpty ? null : await cipher.encrypt(refreshToken),
          ),
          expiresAt: expiresAt,
          tokenType: Value(credentialJson['tokenType'] as String? ?? 'Bearer'),
          updatedAt: now,
        ),
      );
    }

    // 文件夹配置 replace provider config（PRD §16.4）。
    final foldersJson = p['folders'] as List<dynamic>? ?? const [];
    final folders = foldersJson.map((f) {
      final map = f as Map<String, dynamic>;
      return FolderConfigsCompanion.insert(
        providerAccountId: accountIdValue,
        remoteFolderId: map['remoteFolderId'] as String? ?? '',
        folderPathSnapshot: map['folderPathSnapshot'] as String? ?? '',
        folderName: map['folderName'] as String? ?? '',
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
    if (folders.isNotEmpty) {
      await dao.replaceFolders(accountIdValue, folders);
    }
  }
}

/// 供手机端导出 Pairing payload。
Future<Map<String, dynamic>> buildPairingPayload({
  required AppDao dao,
  required TokenCipher cipher,
}) async {
  final accounts = await dao.getAccounts();
  final providers = <Map<String, dynamic>>[];
  for (final account in accounts) {
    if (account.status == AccountStatus.disconnected) continue;
    final cred = await dao.getCredential(account.id);
    String? accessToken;
    String? refreshToken;
    var expiresAt = DateTime.now()
        .add(const Duration(hours: 1))
        .toIso8601String();
    if (cred != null) {
      try {
        accessToken = await cipher.decrypt(cred.accessTokenEncrypted);
        refreshToken = cred.refreshTokenEncrypted == null
            ? null
            : await cipher.decrypt(cred.refreshTokenEncrypted!);
        expiresAt = cred.expiresAt.toIso8601String();
      } catch (_) {
        // 解密失败则不带凭据
      }
    }
    final folders = await dao.getFolders(account.id);
    providers.add({
      'type': account.providerType,
      'account': {
        'accountId': account.accountId,
        'displayName': account.displayName,
      },
      'credential': {
        'accessToken': accessToken ?? '',
        'refreshToken': refreshToken ?? '',
        'expiresAt': expiresAt,
        'tokenType': cred?.tokenType ?? 'Bearer',
      },
      'folders': [
        for (final f in folders)
          {
            'remoteFolderId': f.remoteFolderId,
            'folderPathSnapshot': f.folderPathSnapshot,
            'folderName': f.folderName,
          },
      ],
    });
  }
  return {'v': 1, 'providers': providers};
}
