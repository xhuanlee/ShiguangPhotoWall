import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/crypto/token_cipher.dart';
import '../data/db/app_database.dart';
import '../data/provider/provider_models.dart';
import '../data/provider/provider_registry.dart';
import 'providers.dart';
import 'sync_service.dart';

/// 账号绑定/解绑/重认证服务（PRD §4.1 / §15）。
///
/// - 绑定成功后自动触发首次同步（PRD §10.2）
/// - NEED_REAUTH 绝不删除 FolderConfig / MediaEntity / Preview
class AccountService {
  AccountService({
    required this.dao,
    required this.registry,
    required this.cipher,
    required this.sync,
  });

  final AppDao dao;
  final ProviderRegistry registry;
  final TokenCipher cipher;
  final SyncService sync;

  /// 绑定 / 重新认证。返回错误消息（null = 成功）。
  Future<String?> bind(ProviderType type) async {
    final provider = registry.providerOf(type);
    if (!provider.isConfigured) {
      return '${type.displayName}暂未开放（官方开放平台凭证未配置）';
    }

    final result = await provider.authorize();
    switch (result) {
      case AuthSuccess(:final credentials):
        final now = DateTime.now();
        final existing = await dao.findAccountByType(type.wireName);
        final int accountId;
        if (existing == null) {
          accountId = await dao.upsertAccount(
            ProviderAccountsCompanion.insert(
              providerType: type.wireName,
              accountId: credentials.accountId,
              displayName: Value(type.displayName),
              status: Value(AccountStatus.authenticated),
              createdAt: now,
              updatedAt: now,
              lastAuthenticatedAt: Value(now),
            ),
          );
        } else {
          accountId = existing.id;
          await dao.updateAccountStatus(
            accountId,
            status: AccountStatus.authenticated,
            lastAuthenticatedAt: now,
            lastSyncError: null,
          );
        }
        await dao.upsertCredential(
          CredentialsCompanion.insert(
            providerAccountId: Value(accountId),
            accessTokenEncrypted: await cipher.encrypt(credentials.accessToken),
            refreshTokenEncrypted: Value(
              credentials.refreshToken.isEmpty
                  ? null
                  : await cipher.encrypt(credentials.refreshToken),
            ),
            expiresAt: credentials.expiresAt,
            tokenType: Value(credentials.tokenType),
            updatedAt: now,
          ),
        );
        // 绑定/重认证成功后自动同步（PRD §15：原文件夹配置继续生效）。
        unawaited(
          sync.sync(
            trigger: existing == null
                ? SyncTrigger.initial
                : SyncTrigger.reauth,
            providerAccountId: accountId,
          ),
        );
        return null;
      case AuthUnavailable(:final reason):
        return reason;
      case AuthFailed(:final error):
        return '授权失败：$error';
      case AuthNeedReauth():
        return '授权未完成，请重试';
    }
  }

  /// 解除绑定：删除账号 + 凭据 + 文件夹配置 + 媒体索引（用户显式操作）。
  Future<void> unbind(int accountId, ProviderType type) async {
    final provider = registry.providerOf(type);
    await provider.logoutOrRevoke();
    await dao.deleteMediaByProviderAccount(accountId);
    await dao.deleteFolders(accountId);
    await dao.deleteCredential(accountId);
    await dao.deleteAccount(accountId);
  }
}

final accountServiceProvider = Provider<AccountService>(
  (ref) => AccountService(
    dao: ref.watch(appDaoProvider),
    registry: ref.watch(providerRegistryProvider),
    cipher: ref.watch(tokenCipherProvider),
    sync: ref.watch(syncServiceProvider),
  ),
);
