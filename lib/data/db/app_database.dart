import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'app_database.g.dart';

/// Provider 账号状态（PRD §13 / §14）。
enum AccountStatus { disconnected, authenticated, needReauth, syncing, error }

/// 本地媒体状态。
enum MediaStatus { active, deleted, remoteMissing }

/// 文件夹配置状态（folder ID 在云盘侧不存在时标记 REMOTE_MISSING）。
enum FolderConfigStatus { active, remoteMissing }

/// 同步触发来源。
enum SyncTrigger { manual, initial, pairing, reauth }

/// 同步运行状态。
enum SyncRunStatus { running, success, partialFailure, failed, authFailed }

// ---------------------------------------------------------------------------
// Tables (PRD §13)
// ---------------------------------------------------------------------------

class ProviderAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get providerType => text()();
  TextColumn get accountId => text()();
  TextColumn get displayName => text().withDefault(const Constant(''))();
  TextColumn get status => textEnum<AccountStatus>().withDefault(
    Constant(AccountStatus.disconnected.name),
  )();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastAuthenticatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get lastSyncError => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {providerType, accountId},
  ];
}

class Credentials extends Table {
  IntColumn get providerAccountId => integer()();

  /// AES-GCM 密文，密钥托管于 Android Keystore（PRD §42）。
  TextColumn get accessTokenEncrypted => text()();
  TextColumn get refreshTokenEncrypted => text().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  TextColumn get tokenType => text().withDefault(const Constant('Bearer'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {providerAccountId};
}

class FolderConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get providerAccountId => integer()();
  TextColumn get remoteFolderId => text()();
  TextColumn get folderPathSnapshot => text()();
  TextColumn get folderName => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  BoolColumn get recursive => boolean().withDefault(const Constant(true))();
  TextColumn get status => textEnum<FolderConfigStatus>().withDefault(
    Constant(FolderConfigStatus.active.name),
  )();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {providerAccountId, remoteFolderId},
  ];
}

@TableIndex(name: 'idx_media_capture_time', columns: {#captureTime})
@TableIndex(name: 'idx_media_type_time', columns: {#mediaType, #captureTime})
class MediaItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get providerAccountId => integer()();
  TextColumn get providerType => text()();

  /// 云盘账号标识（同步唯一键组成部分）。
  TextColumn get accountKey => text()();
  TextColumn get remoteFileId => text()();
  TextColumn get parentRemoteFolderId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get mediaType => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get captureTime => dateTime().nullable()();
  DateTimeColumn get modifiedTime => dateTime()();
  TextColumn get remoteVersion => text().nullable()();
  TextColumn get checksum => text().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get containerFormat => text().nullable()();
  TextColumn get videoCodec => text().nullable()();
  TextColumn get audioCodec => text().nullable()();
  TextColumn get originalMimeType => text().nullable()();
  TextColumn get previewPath => text().nullable()();
  TextColumn get status =>
      textEnum<MediaStatus>().withDefault(Constant(MediaStatus.active.name))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {providerType, accountKey, remoteFileId},
  ];
}

class SyncRuns extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get trigger => textEnum<SyncTrigger>()();
  TextColumn get status => textEnum<SyncRunStatus>()();
  IntColumn get foundCount => integer().withDefault(const Constant(0))();
  IntColumn get addedCount => integer().withDefault(const Constant(0))();
  IntColumn get updatedCount => integer().withDefault(const Constant(0))();
  IntColumn get deletedCount => integer().withDefault(const Constant(0))();
  IntColumn get previewCreatedCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get previewDeletedCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get errorCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
}

class PairingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  TextColumn get nonce => text()();
  TextColumn get tvPublicKey => text()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get usedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {sessionId},
  ];
}

// ---------------------------------------------------------------------------
// DAOs
// ---------------------------------------------------------------------------

@DriftAccessor(
  tables: [
    ProviderAccounts,
    Credentials,
    FolderConfigs,
    MediaItems,
    SyncRuns,
    PairingSessions,
  ],
)
class AppDao extends DatabaseAccessor<AppDatabase> with _$AppDaoMixin {
  AppDao(super.db);

  // ---- ProviderAccounts ---------------------------------------------------

  Stream<List<ProviderAccount>> watchAccounts() => (select(
    providerAccounts,
  )..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();

  Future<List<ProviderAccount>> getAccounts() => (select(
    providerAccounts,
  )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Stream<ProviderAccount?> watchAccount(int id) => (select(
    providerAccounts,
  )..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<ProviderAccount?> findAccountByType(String providerType) => (select(
    providerAccounts,
  )..where((t) => t.providerType.equals(providerType))).getSingleOrNull();

  Future<int> upsertAccount(ProviderAccountsCompanion entry) =>
      into(providerAccounts).insert(entry);

  Future<void> updateAccountStatus(
    int id, {
    required AccountStatus status,
    String? lastSyncError,
    DateTime? lastSyncAt,
    DateTime? lastAuthenticatedAt,
  }) => (update(providerAccounts)..where((t) => t.id.equals(id))).write(
    ProviderAccountsCompanion(
      status: Value(status),
      updatedAt: Value(DateTime.now()),
      lastSyncError: Value(lastSyncError),
      lastSyncAt: lastSyncAt == null ? const Value.absent() : Value(lastSyncAt),
      lastAuthenticatedAt: lastAuthenticatedAt == null
          ? const Value.absent()
          : Value(lastAuthenticatedAt),
    ),
  );

  Future<void> deleteAccount(int id) =>
      (delete(providerAccounts)..where((t) => t.id.equals(id))).go();

  // ---- Credentials ----------------------------------------------------------

  Future<Credential?> getCredential(int providerAccountId) =>
      (select(credentials)
            ..where((t) => t.providerAccountId.equals(providerAccountId)))
          .getSingleOrNull();

  Future<void> upsertCredential(CredentialsCompanion entry) => into(credentials)
      .insert(
        entry,
        onConflict: DoUpdate(
          (_) => entry,
          target: [credentials.providerAccountId],
        ),
      );

  Future<void> deleteCredential(int providerAccountId) => (delete(
    credentials,
  )..where((t) => t.providerAccountId.equals(providerAccountId))).go();

  // ---- FolderConfigs --------------------------------------------------------

  Stream<List<FolderConfig>> watchFolders(int providerAccountId) =>
      (select(folderConfigs)
            ..where((t) => t.providerAccountId.equals(providerAccountId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .watch();

  Future<List<FolderConfig>> getFolders(int providerAccountId) => (select(
    folderConfigs,
  )..where((t) => t.providerAccountId.equals(providerAccountId))).get();

  /// replace provider config 语义（PRD §16.4）。
  Future<void> replaceFolders(
    int providerAccountId,
    List<FolderConfigsCompanion> folders,
  ) => transaction(() async {
    await (delete(
      folderConfigs,
    )..where((t) => t.providerAccountId.equals(providerAccountId))).go();
    for (final f in folders) {
      await into(folderConfigs).insert(
        f.copyWith(providerAccountId: Value(providerAccountId)),
        mode: InsertMode.insertOrIgnore,
      );
    }
  });

  Future<void> deleteFolders(int providerAccountId) => (delete(
    folderConfigs,
  )..where((t) => t.providerAccountId.equals(providerAccountId))).go();

  Future<void> markFolderStatus(
    String remoteFolderId,
    FolderConfigStatus status,
  ) =>
      (update(
        folderConfigs,
      )..where((t) => t.remoteFolderId.equals(remoteFolderId))).write(
        FolderConfigsCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // ---- MediaItems -----------------------------------------------------------

  /// 分页查询（PRD §40：禁止 getAllMedia 一次性加载）。
  Stream<List<MediaItem>> watchMediaPage({
    String? mediaType,
    required int limit,
    required int offset,
  }) {
    final query = select(mediaItems)
      ..where(
        (t) =>
            t.status.equalsValue(MediaStatus.active) &
            (mediaType == null
                ? const Constant(true)
                : t.mediaType.equals(mediaType)),
      )
      ..orderBy([
        (t) => OrderingTerm.desc(t.captureTime),
        (t) => OrderingTerm.desc(t.modifiedTime),
        (t) => OrderingTerm.desc(t.createdAt),
      ])
      ..limit(limit, offset: offset);
    return query.watch();
  }

  Future<List<MediaItem>> getMediaPage({
    String? mediaType,
    required int limit,
    required int offset,
  }) {
    final query = select(mediaItems)
      ..where(
        (t) =>
            t.status.equalsValue(MediaStatus.active) &
            (mediaType == null
                ? const Constant(true)
                : t.mediaType.equals(mediaType)),
      )
      ..orderBy([
        (t) => OrderingTerm.desc(t.captureTime),
        (t) => OrderingTerm.desc(t.modifiedTime),
        (t) => OrderingTerm.desc(t.createdAt),
      ])
      ..limit(limit, offset: offset);
    return query.get();
  }

  Future<int> countMedia({String? mediaType}) async {
    final count = countAll();
    final query = selectOnly(mediaItems)
      ..addColumns([count])
      ..where(
        mediaItems.status.equalsValue(MediaStatus.active) &
            (mediaType == null
                ? const Constant(true)
                : mediaItems.mediaType.equals(mediaType)),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Stream<MediaItem?> watchMedia(int id) =>
      (select(mediaItems)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// 按 ID 窗口取媒体（Viewer 预加载邻近项，PRD §24.1）。
  Future<List<MediaItem>> getMediaByIds(List<int> ids) =>
      (select(mediaItems)..where((t) => t.id.isIn(ids))).get();

  Future<List<MediaItem>> getMediaByProviderAccount(int providerAccountId) =>
      (select(
        mediaItems,
      )..where((t) => t.providerAccountId.equals(providerAccountId))).get();

  /// 批量 upsert（PRD §24.5：大批量 upsert 使用批量 DAO，禁止循环逐条事务）。
  Future<void> upsertMediaBatch(List<MediaItemsCompanion> entries) =>
      batch((b) {
        b.insertAll(
          mediaItems,
          entries,
          onConflict: DoUpdate.withExcluded(
            (MediaItems oldRow, MediaItems excluded) =>
                MediaItemsCompanion.custom(
                  parentRemoteFolderId: excluded.parentRemoteFolderId,
                  name: excluded.name,
                  mediaType: excluded.mediaType,
                  mimeType: excluded.mimeType,
                  sizeBytes: excluded.sizeBytes,
                  captureTime: excluded.captureTime,
                  modifiedTime: excluded.modifiedTime,
                  remoteVersion: excluded.remoteVersion,
                  checksum: excluded.checksum,
                  width: excluded.width,
                  height: excluded.height,
                  durationMs: excluded.durationMs,
                  previewPath: excluded.previewPath,
                  status: excluded.status,
                  updatedAt: excluded.updatedAt,
                ),
            target: [
              mediaItems.providerType,
              mediaItems.accountKey,
              mediaItems.remoteFileId,
            ],
          ),
        );
      });

  Future<void> updateMediaPreview(int id, String previewPath) =>
      (update(mediaItems)..where((t) => t.id.equals(id))).write(
        MediaItemsCompanion(
          previewPath: Value(previewPath),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> markMediaStatus(Iterable<int> ids, MediaStatus status) =>
      (update(mediaItems)..where((t) => t.id.isIn(ids))).write(
        MediaItemsCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> deleteMediaByProviderAccount(int providerAccountId) => (delete(
    mediaItems,
  )..where((t) => t.providerAccountId.equals(providerAccountId))).go();

  /// 活跃媒体的所有 preview 相对路径（Preview GC 输入）。
  Future<Set<String>> activePreviewPaths() async {
    final query = selectOnly(mediaItems)
      ..addColumns([mediaItems.previewPath])
      ..where(
        mediaItems.status.equalsValue(MediaStatus.active) &
            mediaItems.previewPath.isNotNull(),
      );
    final rows = await query.get();
    return rows
        .map((r) => r.read(mediaItems.previewPath))
        .whereType<String>()
        .toSet();
  }

  // ---- SyncRuns ---------------------------------------------------------------

  Future<int> startSyncRun(SyncTrigger trigger) => into(syncRuns).insert(
    SyncRunsCompanion.insert(
      startedAt: DateTime.now(),
      trigger: trigger,
      status: SyncRunStatus.running,
    ),
  );

  Future<void> finishSyncRun(
    int runId, {
    required SyncRunStatus status,
    int foundCount = 0,
    int addedCount = 0,
    int updatedCount = 0,
    int deletedCount = 0,
    int previewCreatedCount = 0,
    int previewDeletedCount = 0,
    int errorCount = 0,
    String? errorMessage,
  }) => (update(syncRuns)..where((t) => t.id.equals(runId))).write(
    SyncRunsCompanion(
      finishedAt: Value(DateTime.now()),
      status: Value(status),
      foundCount: Value(foundCount),
      addedCount: Value(addedCount),
      updatedCount: Value(updatedCount),
      deletedCount: Value(deletedCount),
      previewCreatedCount: Value(previewCreatedCount),
      previewDeletedCount: Value(previewDeletedCount),
      errorCount: Value(errorCount),
      errorMessage: Value(errorMessage),
    ),
  );

  Stream<SyncRun?> watchLatestSyncRun() {
    final query = select(syncRuns)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  // ---- PairingSessions ----------------------------------------------------

  Future<void> insertPairingSession(PairingSessionsCompanion entry) =>
      into(pairingSessions).insert(entry, mode: InsertMode.insertOrReplace);

  Future<PairingSession?> getPairingSession(String sessionId) => (select(
    pairingSessions,
  )..where((t) => t.sessionId.equals(sessionId))).getSingleOrNull();

  Future<void> markPairingSessionUsed(String sessionId) =>
      (update(pairingSessions)..where((t) => t.sessionId.equals(sessionId)))
          .write(PairingSessionsCompanion(usedAt: Value(DateTime.now())));

  Future<void> deleteExpiredPairingSessions() => (delete(
    pairingSessions,
  )..where((t) => t.expiresAt.isSmallerThanValue(DateTime.now()))).go();
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    ProviderAccounts,
    Credentials,
    FolderConfigs,
    MediaItems,
    SyncRuns,
    PairingSessions,
  ],
  daos: [AppDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 内存数据库（测试用）。
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // schema 变更必须附 migration test（PRD §55-16）。
      // v1: 初始版本。
    },
  );
}

/// 打开应用数据库（延迟初始化，PRD §24.10）。
AppDatabase openAppDatabase(File file) => AppDatabase(
  LazyDatabase(() async {
    if (file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }
    return NativeDatabase.createInBackground(file);
  }),
);
