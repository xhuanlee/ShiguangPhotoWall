import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show LazyDatabase;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../data/crypto/token_cipher.dart';
import '../data/db/app_database.dart';
import '../data/preview/preview_manager.dart';
import '../data/preview/preview_store.dart';
import '../data/provider/oauth/oauth_core.dart';
import '../data/provider/provider_registry.dart';
import '../data/sync/preview_gc.dart';
import '../data/sync/sync_engine.dart';
import 'browser_oauth_bridge.dart';
import 'settings.dart';
import 'sync_service.dart';

/// SharedPreferences 实例（main 中 override 注入）。
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// 数据库文件（延迟初始化，PRD §24.10）。
Future<File> _databaseFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/database/sgphotowall.db');
}

Future<Directory> _previewDir() async {
  final dir = await getApplicationSupportDirectory();
  return Directory('${dir.path}/cache/preview');
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(
    LazyDatabase(() async {
      final file = await _databaseFile();
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      return NativeDatabase.createInBackground(file);
    }),
  );
  ref.onDispose(db.close);
  return db;
});

final appDaoProvider = Provider<AppDao>(
  (ref) => ref.watch(appDatabaseProvider).appDao,
);

final tokenCipherProvider = Provider<TokenCipher>(
  (ref) => KeystoreTokenCipher(),
);

/// Preview 目录（延迟解析，避免启动期 IO）。
final previewDirProvider = FutureProvider<Directory>((ref) async {
  final dir = await _previewDir();
  if (!dir.existsSync()) dir.createSync(recursive: true);
  return dir;
});

final previewStoreProvider = Provider<PreviewStore>((ref) {
  final dir = ref.watch(previewDirProvider).value;
  return PreviewStore(dir ?? Directory.systemTemp);
});

final previewManagerProvider = Provider<PreviewManager>(
  (ref) => PreviewManager(
    store: ref.watch(previewStoreProvider),
    longEdge: AppConfig.isTv
        ? PreviewStore.tvLongEdge
        : PreviewStore.gridLongEdge,
    concurrency: AppConfig.isTv ? 2 : 3,
  ),
);

final previewGcProvider = Provider<PreviewGarbageCollector>(
  (ref) => PreviewGarbageCollector(
    dao: ref.watch(appDaoProvider),
    store: ref.watch(previewStoreProvider),
  ),
);

/// OAuth 浏览器授权桥（url_launcher + app_links）。
final oAuthAuthorizerProvider = Provider<OAuthAuthorizer>(
  (ref) => createBrowserOAuthAuthorizer(),
);

final providerRegistryProvider = Provider<ProviderRegistry>(
  (ref) => ProviderRegistry(
    dio: Dio(),
    authorizer: ref.watch(oAuthAuthorizerProvider),
  ),
);

final syncEngineProvider = Provider<SyncEngine>(
  (ref) => SyncEngine(
    dao: ref.watch(appDaoProvider),
    registry: ref.watch(providerRegistryProvider),
    cipher: ref.watch(tokenCipherProvider),
    previewStore: ref.watch(previewStoreProvider),
    previewManager: ref.watch(previewManagerProvider),
    gc: ref.watch(previewGcProvider),
  ),
);

/// 同步服务：统一触发入口 + 进度广播（PRD §10.1）。
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref.watch(syncEngineProvider));
  ref.onDispose(service.dispose);
  return service;
});

final syncProgressProvider = StreamProvider<SyncProgress>(
  (ref) => ref.watch(syncServiceProvider).progress,
);

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final repo = SettingsRepository(ref.watch(sharedPreferencesProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

/// 播放设置（同步快照 + 变更通知）。
final playbackSettingsProvider = ChangeNotifierProvider<SettingsRepository>((
  ref,
) {
  return ref.watch(settingsRepositoryProvider);
});

/// Provider 账号流（设置页 + 首页 Reauth Banner）。
final accountsProvider = StreamProvider<List<ProviderAccount>>(
  (ref) => ref.watch(appDaoProvider).watchAccounts(),
);

/// 最近一次同步运行。
final latestSyncRunProvider = StreamProvider<SyncRun?>(
  (ref) => ref.watch(appDaoProvider).watchLatestSyncRun(),
);
