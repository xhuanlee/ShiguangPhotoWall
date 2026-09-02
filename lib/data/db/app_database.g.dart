// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$AppDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProviderAccountsTable get providerAccounts =>
      attachedDatabase.providerAccounts;
  $CredentialsTable get credentials => attachedDatabase.credentials;
  $FolderConfigsTable get folderConfigs => attachedDatabase.folderConfigs;
  $MediaItemsTable get mediaItems => attachedDatabase.mediaItems;
  $SyncRunsTable get syncRuns => attachedDatabase.syncRuns;
  $PairingSessionsTable get pairingSessions => attachedDatabase.pairingSessions;
  AppDaoManager get managers => AppDaoManager(this);
}

class AppDaoManager {
  final _$AppDaoMixin _db;
  AppDaoManager(this._db);
  $$ProviderAccountsTableTableManager get providerAccounts =>
      $$ProviderAccountsTableTableManager(
        _db.attachedDatabase,
        _db.providerAccounts,
      );
  $$CredentialsTableTableManager get credentials =>
      $$CredentialsTableTableManager(_db.attachedDatabase, _db.credentials);
  $$FolderConfigsTableTableManager get folderConfigs =>
      $$FolderConfigsTableTableManager(_db.attachedDatabase, _db.folderConfigs);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db.attachedDatabase, _db.mediaItems);
  $$SyncRunsTableTableManager get syncRuns =>
      $$SyncRunsTableTableManager(_db.attachedDatabase, _db.syncRuns);
  $$PairingSessionsTableTableManager get pairingSessions =>
      $$PairingSessionsTableTableManager(
        _db.attachedDatabase,
        _db.pairingSessions,
      );
}

class $ProviderAccountsTable extends ProviderAccounts
    with TableInfo<$ProviderAccountsTable, ProviderAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerTypeMeta = const VerificationMeta(
    'providerType',
  );
  @override
  late final GeneratedColumn<String> providerType = GeneratedColumn<String>(
    'provider_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(AccountStatus.disconnected.name),
      ).withConverter<AccountStatus>($ProviderAccountsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAuthenticatedAtMeta =
      const VerificationMeta('lastAuthenticatedAt');
  @override
  late final GeneratedColumn<DateTime> lastAuthenticatedAt =
      GeneratedColumn<DateTime>(
        'last_authenticated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncErrorMeta = const VerificationMeta(
    'lastSyncError',
  );
  @override
  late final GeneratedColumn<String> lastSyncError = GeneratedColumn<String>(
    'last_sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerType,
    accountId,
    displayName,
    status,
    createdAt,
    updatedAt,
    lastAuthenticatedAt,
    lastSyncAt,
    lastSyncError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider_type')) {
      context.handle(
        _providerTypeMeta,
        providerType.isAcceptableOrUnknown(
          data['provider_type']!,
          _providerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerTypeMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_authenticated_at')) {
      context.handle(
        _lastAuthenticatedAtMeta,
        lastAuthenticatedAt.isAcceptableOrUnknown(
          data['last_authenticated_at']!,
          _lastAuthenticatedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_error')) {
      context.handle(
        _lastSyncErrorMeta,
        lastSyncError.isAcceptableOrUnknown(
          data['last_sync_error']!,
          _lastSyncErrorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {providerType, accountId},
  ];
  @override
  ProviderAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      providerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_type'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      status: $ProviderAccountsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastAuthenticatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_authenticated_at'],
      ),
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      lastSyncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_error'],
      ),
    );
  }

  @override
  $ProviderAccountsTable createAlias(String alias) {
    return $ProviderAccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountStatus, String, String> $converterstatus =
      const EnumNameConverter<AccountStatus>(AccountStatus.values);
}

class ProviderAccount extends DataClass implements Insertable<ProviderAccount> {
  final int id;
  final String providerType;
  final String accountId;
  final String displayName;
  final AccountStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAuthenticatedAt;
  final DateTime? lastSyncAt;
  final String? lastSyncError;
  const ProviderAccount({
    required this.id,
    required this.providerType,
    required this.accountId,
    required this.displayName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastAuthenticatedAt,
    this.lastSyncAt,
    this.lastSyncError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider_type'] = Variable<String>(providerType);
    map['account_id'] = Variable<String>(accountId);
    map['display_name'] = Variable<String>(displayName);
    {
      map['status'] = Variable<String>(
        $ProviderAccountsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastAuthenticatedAt != null) {
      map['last_authenticated_at'] = Variable<DateTime>(lastAuthenticatedAt);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || lastSyncError != null) {
      map['last_sync_error'] = Variable<String>(lastSyncError);
    }
    return map;
  }

  ProviderAccountsCompanion toCompanion(bool nullToAbsent) {
    return ProviderAccountsCompanion(
      id: Value(id),
      providerType: Value(providerType),
      accountId: Value(accountId),
      displayName: Value(displayName),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastAuthenticatedAt: lastAuthenticatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAuthenticatedAt),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      lastSyncError: lastSyncError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncError),
    );
  }

  factory ProviderAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderAccount(
      id: serializer.fromJson<int>(json['id']),
      providerType: serializer.fromJson<String>(json['providerType']),
      accountId: serializer.fromJson<String>(json['accountId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      status: $ProviderAccountsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastAuthenticatedAt: serializer.fromJson<DateTime?>(
        json['lastAuthenticatedAt'],
      ),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      lastSyncError: serializer.fromJson<String?>(json['lastSyncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerType': serializer.toJson<String>(providerType),
      'accountId': serializer.toJson<String>(accountId),
      'displayName': serializer.toJson<String>(displayName),
      'status': serializer.toJson<String>(
        $ProviderAccountsTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastAuthenticatedAt': serializer.toJson<DateTime?>(lastAuthenticatedAt),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'lastSyncError': serializer.toJson<String?>(lastSyncError),
    };
  }

  ProviderAccount copyWith({
    int? id,
    String? providerType,
    String? accountId,
    String? displayName,
    AccountStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastAuthenticatedAt = const Value.absent(),
    Value<DateTime?> lastSyncAt = const Value.absent(),
    Value<String?> lastSyncError = const Value.absent(),
  }) => ProviderAccount(
    id: id ?? this.id,
    providerType: providerType ?? this.providerType,
    accountId: accountId ?? this.accountId,
    displayName: displayName ?? this.displayName,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastAuthenticatedAt: lastAuthenticatedAt.present
        ? lastAuthenticatedAt.value
        : this.lastAuthenticatedAt,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    lastSyncError: lastSyncError.present
        ? lastSyncError.value
        : this.lastSyncError,
  );
  ProviderAccount copyWithCompanion(ProviderAccountsCompanion data) {
    return ProviderAccount(
      id: data.id.present ? data.id.value : this.id,
      providerType: data.providerType.present
          ? data.providerType.value
          : this.providerType,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastAuthenticatedAt: data.lastAuthenticatedAt.present
          ? data.lastAuthenticatedAt.value
          : this.lastAuthenticatedAt,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      lastSyncError: data.lastSyncError.present
          ? data.lastSyncError.value
          : this.lastSyncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderAccount(')
          ..write('id: $id, ')
          ..write('providerType: $providerType, ')
          ..write('accountId: $accountId, ')
          ..write('displayName: $displayName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastAuthenticatedAt: $lastAuthenticatedAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastSyncError: $lastSyncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerType,
    accountId,
    displayName,
    status,
    createdAt,
    updatedAt,
    lastAuthenticatedAt,
    lastSyncAt,
    lastSyncError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderAccount &&
          other.id == this.id &&
          other.providerType == this.providerType &&
          other.accountId == this.accountId &&
          other.displayName == this.displayName &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastAuthenticatedAt == this.lastAuthenticatedAt &&
          other.lastSyncAt == this.lastSyncAt &&
          other.lastSyncError == this.lastSyncError);
}

class ProviderAccountsCompanion extends UpdateCompanion<ProviderAccount> {
  final Value<int> id;
  final Value<String> providerType;
  final Value<String> accountId;
  final Value<String> displayName;
  final Value<AccountStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastAuthenticatedAt;
  final Value<DateTime?> lastSyncAt;
  final Value<String?> lastSyncError;
  const ProviderAccountsCompanion({
    this.id = const Value.absent(),
    this.providerType = const Value.absent(),
    this.accountId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastAuthenticatedAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.lastSyncError = const Value.absent(),
  });
  ProviderAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String providerType,
    required String accountId,
    this.displayName = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastAuthenticatedAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.lastSyncError = const Value.absent(),
  }) : providerType = Value(providerType),
       accountId = Value(accountId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProviderAccount> custom({
    Expression<int>? id,
    Expression<String>? providerType,
    Expression<String>? accountId,
    Expression<String>? displayName,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastAuthenticatedAt,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? lastSyncError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerType != null) 'provider_type': providerType,
      if (accountId != null) 'account_id': accountId,
      if (displayName != null) 'display_name': displayName,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastAuthenticatedAt != null)
        'last_authenticated_at': lastAuthenticatedAt,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (lastSyncError != null) 'last_sync_error': lastSyncError,
    });
  }

  ProviderAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? providerType,
    Value<String>? accountId,
    Value<String>? displayName,
    Value<AccountStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastAuthenticatedAt,
    Value<DateTime?>? lastSyncAt,
    Value<String?>? lastSyncError,
  }) {
    return ProviderAccountsCompanion(
      id: id ?? this.id,
      providerType: providerType ?? this.providerType,
      accountId: accountId ?? this.accountId,
      displayName: displayName ?? this.displayName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAuthenticatedAt: lastAuthenticatedAt ?? this.lastAuthenticatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastSyncError: lastSyncError ?? this.lastSyncError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (providerType.present) {
      map['provider_type'] = Variable<String>(providerType.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ProviderAccountsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastAuthenticatedAt.present) {
      map['last_authenticated_at'] = Variable<DateTime>(
        lastAuthenticatedAt.value,
      );
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (lastSyncError.present) {
      map['last_sync_error'] = Variable<String>(lastSyncError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderAccountsCompanion(')
          ..write('id: $id, ')
          ..write('providerType: $providerType, ')
          ..write('accountId: $accountId, ')
          ..write('displayName: $displayName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastAuthenticatedAt: $lastAuthenticatedAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('lastSyncError: $lastSyncError')
          ..write(')'))
        .toString();
  }
}

class $CredentialsTable extends Credentials
    with TableInfo<$CredentialsTable, Credential> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CredentialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _providerAccountIdMeta = const VerificationMeta(
    'providerAccountId',
  );
  @override
  late final GeneratedColumn<int> providerAccountId = GeneratedColumn<int>(
    'provider_account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accessTokenEncryptedMeta =
      const VerificationMeta('accessTokenEncrypted');
  @override
  late final GeneratedColumn<String> accessTokenEncrypted =
      GeneratedColumn<String>(
        'access_token_encrypted',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _refreshTokenEncryptedMeta =
      const VerificationMeta('refreshTokenEncrypted');
  @override
  late final GeneratedColumn<String> refreshTokenEncrypted =
      GeneratedColumn<String>(
        'refresh_token_encrypted',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenTypeMeta = const VerificationMeta(
    'tokenType',
  );
  @override
  late final GeneratedColumn<String> tokenType = GeneratedColumn<String>(
    'token_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Bearer'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    providerAccountId,
    accessTokenEncrypted,
    refreshTokenEncrypted,
    expiresAt,
    tokenType,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credentials';
  @override
  VerificationContext validateIntegrity(
    Insertable<Credential> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provider_account_id')) {
      context.handle(
        _providerAccountIdMeta,
        providerAccountId.isAcceptableOrUnknown(
          data['provider_account_id']!,
          _providerAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('access_token_encrypted')) {
      context.handle(
        _accessTokenEncryptedMeta,
        accessTokenEncrypted.isAcceptableOrUnknown(
          data['access_token_encrypted']!,
          _accessTokenEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accessTokenEncryptedMeta);
    }
    if (data.containsKey('refresh_token_encrypted')) {
      context.handle(
        _refreshTokenEncryptedMeta,
        refreshTokenEncrypted.isAcceptableOrUnknown(
          data['refresh_token_encrypted']!,
          _refreshTokenEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('token_type')) {
      context.handle(
        _tokenTypeMeta,
        tokenType.isAcceptableOrUnknown(data['token_type']!, _tokenTypeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {providerAccountId};
  @override
  Credential map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Credential(
      providerAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}provider_account_id'],
      )!,
      accessTokenEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_token_encrypted'],
      )!,
      refreshTokenEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refresh_token_encrypted'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      tokenType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_type'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CredentialsTable createAlias(String alias) {
    return $CredentialsTable(attachedDatabase, alias);
  }
}

class Credential extends DataClass implements Insertable<Credential> {
  final int providerAccountId;

  /// AES-GCM 密文，密钥托管于 Android Keystore（PRD §42）。
  final String accessTokenEncrypted;
  final String? refreshTokenEncrypted;
  final DateTime expiresAt;
  final String tokenType;
  final DateTime updatedAt;
  const Credential({
    required this.providerAccountId,
    required this.accessTokenEncrypted,
    this.refreshTokenEncrypted,
    required this.expiresAt,
    required this.tokenType,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider_account_id'] = Variable<int>(providerAccountId);
    map['access_token_encrypted'] = Variable<String>(accessTokenEncrypted);
    if (!nullToAbsent || refreshTokenEncrypted != null) {
      map['refresh_token_encrypted'] = Variable<String>(refreshTokenEncrypted);
    }
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['token_type'] = Variable<String>(tokenType);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CredentialsCompanion toCompanion(bool nullToAbsent) {
    return CredentialsCompanion(
      providerAccountId: Value(providerAccountId),
      accessTokenEncrypted: Value(accessTokenEncrypted),
      refreshTokenEncrypted: refreshTokenEncrypted == null && nullToAbsent
          ? const Value.absent()
          : Value(refreshTokenEncrypted),
      expiresAt: Value(expiresAt),
      tokenType: Value(tokenType),
      updatedAt: Value(updatedAt),
    );
  }

  factory Credential.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Credential(
      providerAccountId: serializer.fromJson<int>(json['providerAccountId']),
      accessTokenEncrypted: serializer.fromJson<String>(
        json['accessTokenEncrypted'],
      ),
      refreshTokenEncrypted: serializer.fromJson<String?>(
        json['refreshTokenEncrypted'],
      ),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      tokenType: serializer.fromJson<String>(json['tokenType']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'providerAccountId': serializer.toJson<int>(providerAccountId),
      'accessTokenEncrypted': serializer.toJson<String>(accessTokenEncrypted),
      'refreshTokenEncrypted': serializer.toJson<String?>(
        refreshTokenEncrypted,
      ),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'tokenType': serializer.toJson<String>(tokenType),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Credential copyWith({
    int? providerAccountId,
    String? accessTokenEncrypted,
    Value<String?> refreshTokenEncrypted = const Value.absent(),
    DateTime? expiresAt,
    String? tokenType,
    DateTime? updatedAt,
  }) => Credential(
    providerAccountId: providerAccountId ?? this.providerAccountId,
    accessTokenEncrypted: accessTokenEncrypted ?? this.accessTokenEncrypted,
    refreshTokenEncrypted: refreshTokenEncrypted.present
        ? refreshTokenEncrypted.value
        : this.refreshTokenEncrypted,
    expiresAt: expiresAt ?? this.expiresAt,
    tokenType: tokenType ?? this.tokenType,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Credential copyWithCompanion(CredentialsCompanion data) {
    return Credential(
      providerAccountId: data.providerAccountId.present
          ? data.providerAccountId.value
          : this.providerAccountId,
      accessTokenEncrypted: data.accessTokenEncrypted.present
          ? data.accessTokenEncrypted.value
          : this.accessTokenEncrypted,
      refreshTokenEncrypted: data.refreshTokenEncrypted.present
          ? data.refreshTokenEncrypted.value
          : this.refreshTokenEncrypted,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      tokenType: data.tokenType.present ? data.tokenType.value : this.tokenType,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Credential(')
          ..write('providerAccountId: $providerAccountId, ')
          ..write('accessTokenEncrypted: $accessTokenEncrypted, ')
          ..write('refreshTokenEncrypted: $refreshTokenEncrypted, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('tokenType: $tokenType, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    providerAccountId,
    accessTokenEncrypted,
    refreshTokenEncrypted,
    expiresAt,
    tokenType,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Credential &&
          other.providerAccountId == this.providerAccountId &&
          other.accessTokenEncrypted == this.accessTokenEncrypted &&
          other.refreshTokenEncrypted == this.refreshTokenEncrypted &&
          other.expiresAt == this.expiresAt &&
          other.tokenType == this.tokenType &&
          other.updatedAt == this.updatedAt);
}

class CredentialsCompanion extends UpdateCompanion<Credential> {
  final Value<int> providerAccountId;
  final Value<String> accessTokenEncrypted;
  final Value<String?> refreshTokenEncrypted;
  final Value<DateTime> expiresAt;
  final Value<String> tokenType;
  final Value<DateTime> updatedAt;
  const CredentialsCompanion({
    this.providerAccountId = const Value.absent(),
    this.accessTokenEncrypted = const Value.absent(),
    this.refreshTokenEncrypted = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.tokenType = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CredentialsCompanion.insert({
    this.providerAccountId = const Value.absent(),
    required String accessTokenEncrypted,
    this.refreshTokenEncrypted = const Value.absent(),
    required DateTime expiresAt,
    this.tokenType = const Value.absent(),
    required DateTime updatedAt,
  }) : accessTokenEncrypted = Value(accessTokenEncrypted),
       expiresAt = Value(expiresAt),
       updatedAt = Value(updatedAt);
  static Insertable<Credential> custom({
    Expression<int>? providerAccountId,
    Expression<String>? accessTokenEncrypted,
    Expression<String>? refreshTokenEncrypted,
    Expression<DateTime>? expiresAt,
    Expression<String>? tokenType,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (providerAccountId != null) 'provider_account_id': providerAccountId,
      if (accessTokenEncrypted != null)
        'access_token_encrypted': accessTokenEncrypted,
      if (refreshTokenEncrypted != null)
        'refresh_token_encrypted': refreshTokenEncrypted,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (tokenType != null) 'token_type': tokenType,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CredentialsCompanion copyWith({
    Value<int>? providerAccountId,
    Value<String>? accessTokenEncrypted,
    Value<String?>? refreshTokenEncrypted,
    Value<DateTime>? expiresAt,
    Value<String>? tokenType,
    Value<DateTime>? updatedAt,
  }) {
    return CredentialsCompanion(
      providerAccountId: providerAccountId ?? this.providerAccountId,
      accessTokenEncrypted: accessTokenEncrypted ?? this.accessTokenEncrypted,
      refreshTokenEncrypted:
          refreshTokenEncrypted ?? this.refreshTokenEncrypted,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (providerAccountId.present) {
      map['provider_account_id'] = Variable<int>(providerAccountId.value);
    }
    if (accessTokenEncrypted.present) {
      map['access_token_encrypted'] = Variable<String>(
        accessTokenEncrypted.value,
      );
    }
    if (refreshTokenEncrypted.present) {
      map['refresh_token_encrypted'] = Variable<String>(
        refreshTokenEncrypted.value,
      );
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (tokenType.present) {
      map['token_type'] = Variable<String>(tokenType.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CredentialsCompanion(')
          ..write('providerAccountId: $providerAccountId, ')
          ..write('accessTokenEncrypted: $accessTokenEncrypted, ')
          ..write('refreshTokenEncrypted: $refreshTokenEncrypted, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('tokenType: $tokenType, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FolderConfigsTable extends FolderConfigs
    with TableInfo<$FolderConfigsTable, FolderConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FolderConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerAccountIdMeta = const VerificationMeta(
    'providerAccountId',
  );
  @override
  late final GeneratedColumn<int> providerAccountId = GeneratedColumn<int>(
    'provider_account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteFolderIdMeta = const VerificationMeta(
    'remoteFolderId',
  );
  @override
  late final GeneratedColumn<String> remoteFolderId = GeneratedColumn<String>(
    'remote_folder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderPathSnapshotMeta =
      const VerificationMeta('folderPathSnapshot');
  @override
  late final GeneratedColumn<String> folderPathSnapshot =
      GeneratedColumn<String>(
        'folder_path_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _folderNameMeta = const VerificationMeta(
    'folderName',
  );
  @override
  late final GeneratedColumn<String> folderName = GeneratedColumn<String>(
    'folder_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _recursiveMeta = const VerificationMeta(
    'recursive',
  );
  @override
  late final GeneratedColumn<bool> recursive = GeneratedColumn<bool>(
    'recursive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recursive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FolderConfigStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(FolderConfigStatus.active.name),
  ).withConverter<FolderConfigStatus>($FolderConfigsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerAccountId,
    remoteFolderId,
    folderPathSnapshot,
    folderName,
    enabled,
    recursive,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FolderConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider_account_id')) {
      context.handle(
        _providerAccountIdMeta,
        providerAccountId.isAcceptableOrUnknown(
          data['provider_account_id']!,
          _providerAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerAccountIdMeta);
    }
    if (data.containsKey('remote_folder_id')) {
      context.handle(
        _remoteFolderIdMeta,
        remoteFolderId.isAcceptableOrUnknown(
          data['remote_folder_id']!,
          _remoteFolderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteFolderIdMeta);
    }
    if (data.containsKey('folder_path_snapshot')) {
      context.handle(
        _folderPathSnapshotMeta,
        folderPathSnapshot.isAcceptableOrUnknown(
          data['folder_path_snapshot']!,
          _folderPathSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_folderPathSnapshotMeta);
    }
    if (data.containsKey('folder_name')) {
      context.handle(
        _folderNameMeta,
        folderName.isAcceptableOrUnknown(data['folder_name']!, _folderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_folderNameMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('recursive')) {
      context.handle(
        _recursiveMeta,
        recursive.isAcceptableOrUnknown(data['recursive']!, _recursiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {providerAccountId, remoteFolderId},
  ];
  @override
  FolderConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      providerAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}provider_account_id'],
      )!,
      remoteFolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_folder_id'],
      )!,
      folderPathSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_path_snapshot'],
      )!,
      folderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_name'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      recursive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recursive'],
      )!,
      status: $FolderConfigsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FolderConfigsTable createAlias(String alias) {
    return $FolderConfigsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FolderConfigStatus, String, String>
  $converterstatus = const EnumNameConverter<FolderConfigStatus>(
    FolderConfigStatus.values,
  );
}

class FolderConfig extends DataClass implements Insertable<FolderConfig> {
  final int id;
  final int providerAccountId;
  final String remoteFolderId;
  final String folderPathSnapshot;
  final String folderName;
  final bool enabled;
  final bool recursive;
  final FolderConfigStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FolderConfig({
    required this.id,
    required this.providerAccountId,
    required this.remoteFolderId,
    required this.folderPathSnapshot,
    required this.folderName,
    required this.enabled,
    required this.recursive,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider_account_id'] = Variable<int>(providerAccountId);
    map['remote_folder_id'] = Variable<String>(remoteFolderId);
    map['folder_path_snapshot'] = Variable<String>(folderPathSnapshot);
    map['folder_name'] = Variable<String>(folderName);
    map['enabled'] = Variable<bool>(enabled);
    map['recursive'] = Variable<bool>(recursive);
    {
      map['status'] = Variable<String>(
        $FolderConfigsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FolderConfigsCompanion toCompanion(bool nullToAbsent) {
    return FolderConfigsCompanion(
      id: Value(id),
      providerAccountId: Value(providerAccountId),
      remoteFolderId: Value(remoteFolderId),
      folderPathSnapshot: Value(folderPathSnapshot),
      folderName: Value(folderName),
      enabled: Value(enabled),
      recursive: Value(recursive),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FolderConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderConfig(
      id: serializer.fromJson<int>(json['id']),
      providerAccountId: serializer.fromJson<int>(json['providerAccountId']),
      remoteFolderId: serializer.fromJson<String>(json['remoteFolderId']),
      folderPathSnapshot: serializer.fromJson<String>(
        json['folderPathSnapshot'],
      ),
      folderName: serializer.fromJson<String>(json['folderName']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      recursive: serializer.fromJson<bool>(json['recursive']),
      status: $FolderConfigsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerAccountId': serializer.toJson<int>(providerAccountId),
      'remoteFolderId': serializer.toJson<String>(remoteFolderId),
      'folderPathSnapshot': serializer.toJson<String>(folderPathSnapshot),
      'folderName': serializer.toJson<String>(folderName),
      'enabled': serializer.toJson<bool>(enabled),
      'recursive': serializer.toJson<bool>(recursive),
      'status': serializer.toJson<String>(
        $FolderConfigsTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FolderConfig copyWith({
    int? id,
    int? providerAccountId,
    String? remoteFolderId,
    String? folderPathSnapshot,
    String? folderName,
    bool? enabled,
    bool? recursive,
    FolderConfigStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FolderConfig(
    id: id ?? this.id,
    providerAccountId: providerAccountId ?? this.providerAccountId,
    remoteFolderId: remoteFolderId ?? this.remoteFolderId,
    folderPathSnapshot: folderPathSnapshot ?? this.folderPathSnapshot,
    folderName: folderName ?? this.folderName,
    enabled: enabled ?? this.enabled,
    recursive: recursive ?? this.recursive,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FolderConfig copyWithCompanion(FolderConfigsCompanion data) {
    return FolderConfig(
      id: data.id.present ? data.id.value : this.id,
      providerAccountId: data.providerAccountId.present
          ? data.providerAccountId.value
          : this.providerAccountId,
      remoteFolderId: data.remoteFolderId.present
          ? data.remoteFolderId.value
          : this.remoteFolderId,
      folderPathSnapshot: data.folderPathSnapshot.present
          ? data.folderPathSnapshot.value
          : this.folderPathSnapshot,
      folderName: data.folderName.present
          ? data.folderName.value
          : this.folderName,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      recursive: data.recursive.present ? data.recursive.value : this.recursive,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderConfig(')
          ..write('id: $id, ')
          ..write('providerAccountId: $providerAccountId, ')
          ..write('remoteFolderId: $remoteFolderId, ')
          ..write('folderPathSnapshot: $folderPathSnapshot, ')
          ..write('folderName: $folderName, ')
          ..write('enabled: $enabled, ')
          ..write('recursive: $recursive, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerAccountId,
    remoteFolderId,
    folderPathSnapshot,
    folderName,
    enabled,
    recursive,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderConfig &&
          other.id == this.id &&
          other.providerAccountId == this.providerAccountId &&
          other.remoteFolderId == this.remoteFolderId &&
          other.folderPathSnapshot == this.folderPathSnapshot &&
          other.folderName == this.folderName &&
          other.enabled == this.enabled &&
          other.recursive == this.recursive &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FolderConfigsCompanion extends UpdateCompanion<FolderConfig> {
  final Value<int> id;
  final Value<int> providerAccountId;
  final Value<String> remoteFolderId;
  final Value<String> folderPathSnapshot;
  final Value<String> folderName;
  final Value<bool> enabled;
  final Value<bool> recursive;
  final Value<FolderConfigStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const FolderConfigsCompanion({
    this.id = const Value.absent(),
    this.providerAccountId = const Value.absent(),
    this.remoteFolderId = const Value.absent(),
    this.folderPathSnapshot = const Value.absent(),
    this.folderName = const Value.absent(),
    this.enabled = const Value.absent(),
    this.recursive = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FolderConfigsCompanion.insert({
    this.id = const Value.absent(),
    required int providerAccountId,
    required String remoteFolderId,
    required String folderPathSnapshot,
    required String folderName,
    this.enabled = const Value.absent(),
    this.recursive = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : providerAccountId = Value(providerAccountId),
       remoteFolderId = Value(remoteFolderId),
       folderPathSnapshot = Value(folderPathSnapshot),
       folderName = Value(folderName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FolderConfig> custom({
    Expression<int>? id,
    Expression<int>? providerAccountId,
    Expression<String>? remoteFolderId,
    Expression<String>? folderPathSnapshot,
    Expression<String>? folderName,
    Expression<bool>? enabled,
    Expression<bool>? recursive,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerAccountId != null) 'provider_account_id': providerAccountId,
      if (remoteFolderId != null) 'remote_folder_id': remoteFolderId,
      if (folderPathSnapshot != null)
        'folder_path_snapshot': folderPathSnapshot,
      if (folderName != null) 'folder_name': folderName,
      if (enabled != null) 'enabled': enabled,
      if (recursive != null) 'recursive': recursive,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FolderConfigsCompanion copyWith({
    Value<int>? id,
    Value<int>? providerAccountId,
    Value<String>? remoteFolderId,
    Value<String>? folderPathSnapshot,
    Value<String>? folderName,
    Value<bool>? enabled,
    Value<bool>? recursive,
    Value<FolderConfigStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return FolderConfigsCompanion(
      id: id ?? this.id,
      providerAccountId: providerAccountId ?? this.providerAccountId,
      remoteFolderId: remoteFolderId ?? this.remoteFolderId,
      folderPathSnapshot: folderPathSnapshot ?? this.folderPathSnapshot,
      folderName: folderName ?? this.folderName,
      enabled: enabled ?? this.enabled,
      recursive: recursive ?? this.recursive,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (providerAccountId.present) {
      map['provider_account_id'] = Variable<int>(providerAccountId.value);
    }
    if (remoteFolderId.present) {
      map['remote_folder_id'] = Variable<String>(remoteFolderId.value);
    }
    if (folderPathSnapshot.present) {
      map['folder_path_snapshot'] = Variable<String>(folderPathSnapshot.value);
    }
    if (folderName.present) {
      map['folder_name'] = Variable<String>(folderName.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (recursive.present) {
      map['recursive'] = Variable<bool>(recursive.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $FolderConfigsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FolderConfigsCompanion(')
          ..write('id: $id, ')
          ..write('providerAccountId: $providerAccountId, ')
          ..write('remoteFolderId: $remoteFolderId, ')
          ..write('folderPathSnapshot: $folderPathSnapshot, ')
          ..write('folderName: $folderName, ')
          ..write('enabled: $enabled, ')
          ..write('recursive: $recursive, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _providerAccountIdMeta = const VerificationMeta(
    'providerAccountId',
  );
  @override
  late final GeneratedColumn<int> providerAccountId = GeneratedColumn<int>(
    'provider_account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerTypeMeta = const VerificationMeta(
    'providerType',
  );
  @override
  late final GeneratedColumn<String> providerType = GeneratedColumn<String>(
    'provider_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountKeyMeta = const VerificationMeta(
    'accountKey',
  );
  @override
  late final GeneratedColumn<String> accountKey = GeneratedColumn<String>(
    'account_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteFileIdMeta = const VerificationMeta(
    'remoteFileId',
  );
  @override
  late final GeneratedColumn<String> remoteFileId = GeneratedColumn<String>(
    'remote_file_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentRemoteFolderIdMeta =
      const VerificationMeta('parentRemoteFolderId');
  @override
  late final GeneratedColumn<String> parentRemoteFolderId =
      GeneratedColumn<String>(
        'parent_remote_folder_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captureTimeMeta = const VerificationMeta(
    'captureTime',
  );
  @override
  late final GeneratedColumn<DateTime> captureTime = GeneratedColumn<DateTime>(
    'capture_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedTimeMeta = const VerificationMeta(
    'modifiedTime',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedTime = GeneratedColumn<DateTime>(
    'modified_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteVersionMeta = const VerificationMeta(
    'remoteVersion',
  );
  @override
  late final GeneratedColumn<String> remoteVersion = GeneratedColumn<String>(
    'remote_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _containerFormatMeta = const VerificationMeta(
    'containerFormat',
  );
  @override
  late final GeneratedColumn<String> containerFormat = GeneratedColumn<String>(
    'container_format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _videoCodecMeta = const VerificationMeta(
    'videoCodec',
  );
  @override
  late final GeneratedColumn<String> videoCodec = GeneratedColumn<String>(
    'video_codec',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioCodecMeta = const VerificationMeta(
    'audioCodec',
  );
  @override
  late final GeneratedColumn<String> audioCodec = GeneratedColumn<String>(
    'audio_codec',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalMimeTypeMeta = const VerificationMeta(
    'originalMimeType',
  );
  @override
  late final GeneratedColumn<String> originalMimeType = GeneratedColumn<String>(
    'original_mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previewPathMeta = const VerificationMeta(
    'previewPath',
  );
  @override
  late final GeneratedColumn<String> previewPath = GeneratedColumn<String>(
    'preview_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MediaStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(MediaStatus.active.name),
      ).withConverter<MediaStatus>($MediaItemsTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerAccountId,
    providerType,
    accountKey,
    remoteFileId,
    parentRemoteFolderId,
    name,
    mediaType,
    mimeType,
    sizeBytes,
    captureTime,
    modifiedTime,
    remoteVersion,
    checksum,
    width,
    height,
    durationMs,
    containerFormat,
    videoCodec,
    audioCodec,
    originalMimeType,
    previewPath,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('provider_account_id')) {
      context.handle(
        _providerAccountIdMeta,
        providerAccountId.isAcceptableOrUnknown(
          data['provider_account_id']!,
          _providerAccountIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerAccountIdMeta);
    }
    if (data.containsKey('provider_type')) {
      context.handle(
        _providerTypeMeta,
        providerType.isAcceptableOrUnknown(
          data['provider_type']!,
          _providerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_providerTypeMeta);
    }
    if (data.containsKey('account_key')) {
      context.handle(
        _accountKeyMeta,
        accountKey.isAcceptableOrUnknown(data['account_key']!, _accountKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_accountKeyMeta);
    }
    if (data.containsKey('remote_file_id')) {
      context.handle(
        _remoteFileIdMeta,
        remoteFileId.isAcceptableOrUnknown(
          data['remote_file_id']!,
          _remoteFileIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteFileIdMeta);
    }
    if (data.containsKey('parent_remote_folder_id')) {
      context.handle(
        _parentRemoteFolderIdMeta,
        parentRemoteFolderId.isAcceptableOrUnknown(
          data['parent_remote_folder_id']!,
          _parentRemoteFolderIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('capture_time')) {
      context.handle(
        _captureTimeMeta,
        captureTime.isAcceptableOrUnknown(
          data['capture_time']!,
          _captureTimeMeta,
        ),
      );
    }
    if (data.containsKey('modified_time')) {
      context.handle(
        _modifiedTimeMeta,
        modifiedTime.isAcceptableOrUnknown(
          data['modified_time']!,
          _modifiedTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modifiedTimeMeta);
    }
    if (data.containsKey('remote_version')) {
      context.handle(
        _remoteVersionMeta,
        remoteVersion.isAcceptableOrUnknown(
          data['remote_version']!,
          _remoteVersionMeta,
        ),
      );
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('container_format')) {
      context.handle(
        _containerFormatMeta,
        containerFormat.isAcceptableOrUnknown(
          data['container_format']!,
          _containerFormatMeta,
        ),
      );
    }
    if (data.containsKey('video_codec')) {
      context.handle(
        _videoCodecMeta,
        videoCodec.isAcceptableOrUnknown(data['video_codec']!, _videoCodecMeta),
      );
    }
    if (data.containsKey('audio_codec')) {
      context.handle(
        _audioCodecMeta,
        audioCodec.isAcceptableOrUnknown(data['audio_codec']!, _audioCodecMeta),
      );
    }
    if (data.containsKey('original_mime_type')) {
      context.handle(
        _originalMimeTypeMeta,
        originalMimeType.isAcceptableOrUnknown(
          data['original_mime_type']!,
          _originalMimeTypeMeta,
        ),
      );
    }
    if (data.containsKey('preview_path')) {
      context.handle(
        _previewPathMeta,
        previewPath.isAcceptableOrUnknown(
          data['preview_path']!,
          _previewPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {providerType, accountKey, remoteFileId},
  ];
  @override
  MediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      providerAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}provider_account_id'],
      )!,
      providerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_type'],
      )!,
      accountKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_key'],
      )!,
      remoteFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_file_id'],
      )!,
      parentRemoteFolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_remote_folder_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      captureTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}capture_time'],
      ),
      modifiedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_time'],
      )!,
      remoteVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_version'],
      ),
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      containerFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}container_format'],
      ),
      videoCodec: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_codec'],
      ),
      audioCodec: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_codec'],
      ),
      originalMimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_mime_type'],
      ),
      previewPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preview_path'],
      ),
      status: $MediaItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MediaStatus, String, String> $converterstatus =
      const EnumNameConverter<MediaStatus>(MediaStatus.values);
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final int id;
  final int providerAccountId;
  final String providerType;

  /// 云盘账号标识（同步唯一键组成部分）。
  final String accountKey;
  final String remoteFileId;
  final String? parentRemoteFolderId;
  final String name;
  final String mediaType;
  final String mimeType;
  final int sizeBytes;
  final DateTime? captureTime;
  final DateTime modifiedTime;
  final String? remoteVersion;
  final String? checksum;
  final int? width;
  final int? height;
  final int? durationMs;
  final String? containerFormat;
  final String? videoCodec;
  final String? audioCodec;
  final String? originalMimeType;
  final String? previewPath;
  final MediaStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MediaItem({
    required this.id,
    required this.providerAccountId,
    required this.providerType,
    required this.accountKey,
    required this.remoteFileId,
    this.parentRemoteFolderId,
    required this.name,
    required this.mediaType,
    required this.mimeType,
    required this.sizeBytes,
    this.captureTime,
    required this.modifiedTime,
    this.remoteVersion,
    this.checksum,
    this.width,
    this.height,
    this.durationMs,
    this.containerFormat,
    this.videoCodec,
    this.audioCodec,
    this.originalMimeType,
    this.previewPath,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['provider_account_id'] = Variable<int>(providerAccountId);
    map['provider_type'] = Variable<String>(providerType);
    map['account_key'] = Variable<String>(accountKey);
    map['remote_file_id'] = Variable<String>(remoteFileId);
    if (!nullToAbsent || parentRemoteFolderId != null) {
      map['parent_remote_folder_id'] = Variable<String>(parentRemoteFolderId);
    }
    map['name'] = Variable<String>(name);
    map['media_type'] = Variable<String>(mediaType);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || captureTime != null) {
      map['capture_time'] = Variable<DateTime>(captureTime);
    }
    map['modified_time'] = Variable<DateTime>(modifiedTime);
    if (!nullToAbsent || remoteVersion != null) {
      map['remote_version'] = Variable<String>(remoteVersion);
    }
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || containerFormat != null) {
      map['container_format'] = Variable<String>(containerFormat);
    }
    if (!nullToAbsent || videoCodec != null) {
      map['video_codec'] = Variable<String>(videoCodec);
    }
    if (!nullToAbsent || audioCodec != null) {
      map['audio_codec'] = Variable<String>(audioCodec);
    }
    if (!nullToAbsent || originalMimeType != null) {
      map['original_mime_type'] = Variable<String>(originalMimeType);
    }
    if (!nullToAbsent || previewPath != null) {
      map['preview_path'] = Variable<String>(previewPath);
    }
    {
      map['status'] = Variable<String>(
        $MediaItemsTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      id: Value(id),
      providerAccountId: Value(providerAccountId),
      providerType: Value(providerType),
      accountKey: Value(accountKey),
      remoteFileId: Value(remoteFileId),
      parentRemoteFolderId: parentRemoteFolderId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentRemoteFolderId),
      name: Value(name),
      mediaType: Value(mediaType),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      captureTime: captureTime == null && nullToAbsent
          ? const Value.absent()
          : Value(captureTime),
      modifiedTime: Value(modifiedTime),
      remoteVersion: remoteVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteVersion),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      containerFormat: containerFormat == null && nullToAbsent
          ? const Value.absent()
          : Value(containerFormat),
      videoCodec: videoCodec == null && nullToAbsent
          ? const Value.absent()
          : Value(videoCodec),
      audioCodec: audioCodec == null && nullToAbsent
          ? const Value.absent()
          : Value(audioCodec),
      originalMimeType: originalMimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(originalMimeType),
      previewPath: previewPath == null && nullToAbsent
          ? const Value.absent()
          : Value(previewPath),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MediaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItem(
      id: serializer.fromJson<int>(json['id']),
      providerAccountId: serializer.fromJson<int>(json['providerAccountId']),
      providerType: serializer.fromJson<String>(json['providerType']),
      accountKey: serializer.fromJson<String>(json['accountKey']),
      remoteFileId: serializer.fromJson<String>(json['remoteFileId']),
      parentRemoteFolderId: serializer.fromJson<String?>(
        json['parentRemoteFolderId'],
      ),
      name: serializer.fromJson<String>(json['name']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      captureTime: serializer.fromJson<DateTime?>(json['captureTime']),
      modifiedTime: serializer.fromJson<DateTime>(json['modifiedTime']),
      remoteVersion: serializer.fromJson<String?>(json['remoteVersion']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      containerFormat: serializer.fromJson<String?>(json['containerFormat']),
      videoCodec: serializer.fromJson<String?>(json['videoCodec']),
      audioCodec: serializer.fromJson<String?>(json['audioCodec']),
      originalMimeType: serializer.fromJson<String?>(json['originalMimeType']),
      previewPath: serializer.fromJson<String?>(json['previewPath']),
      status: $MediaItemsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'providerAccountId': serializer.toJson<int>(providerAccountId),
      'providerType': serializer.toJson<String>(providerType),
      'accountKey': serializer.toJson<String>(accountKey),
      'remoteFileId': serializer.toJson<String>(remoteFileId),
      'parentRemoteFolderId': serializer.toJson<String?>(parentRemoteFolderId),
      'name': serializer.toJson<String>(name),
      'mediaType': serializer.toJson<String>(mediaType),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'captureTime': serializer.toJson<DateTime?>(captureTime),
      'modifiedTime': serializer.toJson<DateTime>(modifiedTime),
      'remoteVersion': serializer.toJson<String?>(remoteVersion),
      'checksum': serializer.toJson<String?>(checksum),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'durationMs': serializer.toJson<int?>(durationMs),
      'containerFormat': serializer.toJson<String?>(containerFormat),
      'videoCodec': serializer.toJson<String?>(videoCodec),
      'audioCodec': serializer.toJson<String?>(audioCodec),
      'originalMimeType': serializer.toJson<String?>(originalMimeType),
      'previewPath': serializer.toJson<String?>(previewPath),
      'status': serializer.toJson<String>(
        $MediaItemsTable.$converterstatus.toJson(status),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MediaItem copyWith({
    int? id,
    int? providerAccountId,
    String? providerType,
    String? accountKey,
    String? remoteFileId,
    Value<String?> parentRemoteFolderId = const Value.absent(),
    String? name,
    String? mediaType,
    String? mimeType,
    int? sizeBytes,
    Value<DateTime?> captureTime = const Value.absent(),
    DateTime? modifiedTime,
    Value<String?> remoteVersion = const Value.absent(),
    Value<String?> checksum = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> containerFormat = const Value.absent(),
    Value<String?> videoCodec = const Value.absent(),
    Value<String?> audioCodec = const Value.absent(),
    Value<String?> originalMimeType = const Value.absent(),
    Value<String?> previewPath = const Value.absent(),
    MediaStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MediaItem(
    id: id ?? this.id,
    providerAccountId: providerAccountId ?? this.providerAccountId,
    providerType: providerType ?? this.providerType,
    accountKey: accountKey ?? this.accountKey,
    remoteFileId: remoteFileId ?? this.remoteFileId,
    parentRemoteFolderId: parentRemoteFolderId.present
        ? parentRemoteFolderId.value
        : this.parentRemoteFolderId,
    name: name ?? this.name,
    mediaType: mediaType ?? this.mediaType,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    captureTime: captureTime.present ? captureTime.value : this.captureTime,
    modifiedTime: modifiedTime ?? this.modifiedTime,
    remoteVersion: remoteVersion.present
        ? remoteVersion.value
        : this.remoteVersion,
    checksum: checksum.present ? checksum.value : this.checksum,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    containerFormat: containerFormat.present
        ? containerFormat.value
        : this.containerFormat,
    videoCodec: videoCodec.present ? videoCodec.value : this.videoCodec,
    audioCodec: audioCodec.present ? audioCodec.value : this.audioCodec,
    originalMimeType: originalMimeType.present
        ? originalMimeType.value
        : this.originalMimeType,
    previewPath: previewPath.present ? previewPath.value : this.previewPath,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MediaItem copyWithCompanion(MediaItemsCompanion data) {
    return MediaItem(
      id: data.id.present ? data.id.value : this.id,
      providerAccountId: data.providerAccountId.present
          ? data.providerAccountId.value
          : this.providerAccountId,
      providerType: data.providerType.present
          ? data.providerType.value
          : this.providerType,
      accountKey: data.accountKey.present
          ? data.accountKey.value
          : this.accountKey,
      remoteFileId: data.remoteFileId.present
          ? data.remoteFileId.value
          : this.remoteFileId,
      parentRemoteFolderId: data.parentRemoteFolderId.present
          ? data.parentRemoteFolderId.value
          : this.parentRemoteFolderId,
      name: data.name.present ? data.name.value : this.name,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      captureTime: data.captureTime.present
          ? data.captureTime.value
          : this.captureTime,
      modifiedTime: data.modifiedTime.present
          ? data.modifiedTime.value
          : this.modifiedTime,
      remoteVersion: data.remoteVersion.present
          ? data.remoteVersion.value
          : this.remoteVersion,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      containerFormat: data.containerFormat.present
          ? data.containerFormat.value
          : this.containerFormat,
      videoCodec: data.videoCodec.present
          ? data.videoCodec.value
          : this.videoCodec,
      audioCodec: data.audioCodec.present
          ? data.audioCodec.value
          : this.audioCodec,
      originalMimeType: data.originalMimeType.present
          ? data.originalMimeType.value
          : this.originalMimeType,
      previewPath: data.previewPath.present
          ? data.previewPath.value
          : this.previewPath,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItem(')
          ..write('id: $id, ')
          ..write('providerAccountId: $providerAccountId, ')
          ..write('providerType: $providerType, ')
          ..write('accountKey: $accountKey, ')
          ..write('remoteFileId: $remoteFileId, ')
          ..write('parentRemoteFolderId: $parentRemoteFolderId, ')
          ..write('name: $name, ')
          ..write('mediaType: $mediaType, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('captureTime: $captureTime, ')
          ..write('modifiedTime: $modifiedTime, ')
          ..write('remoteVersion: $remoteVersion, ')
          ..write('checksum: $checksum, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('containerFormat: $containerFormat, ')
          ..write('videoCodec: $videoCodec, ')
          ..write('audioCodec: $audioCodec, ')
          ..write('originalMimeType: $originalMimeType, ')
          ..write('previewPath: $previewPath, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    providerAccountId,
    providerType,
    accountKey,
    remoteFileId,
    parentRemoteFolderId,
    name,
    mediaType,
    mimeType,
    sizeBytes,
    captureTime,
    modifiedTime,
    remoteVersion,
    checksum,
    width,
    height,
    durationMs,
    containerFormat,
    videoCodec,
    audioCodec,
    originalMimeType,
    previewPath,
    status,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItem &&
          other.id == this.id &&
          other.providerAccountId == this.providerAccountId &&
          other.providerType == this.providerType &&
          other.accountKey == this.accountKey &&
          other.remoteFileId == this.remoteFileId &&
          other.parentRemoteFolderId == this.parentRemoteFolderId &&
          other.name == this.name &&
          other.mediaType == this.mediaType &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.captureTime == this.captureTime &&
          other.modifiedTime == this.modifiedTime &&
          other.remoteVersion == this.remoteVersion &&
          other.checksum == this.checksum &&
          other.width == this.width &&
          other.height == this.height &&
          other.durationMs == this.durationMs &&
          other.containerFormat == this.containerFormat &&
          other.videoCodec == this.videoCodec &&
          other.audioCodec == this.audioCodec &&
          other.originalMimeType == this.originalMimeType &&
          other.previewPath == this.previewPath &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MediaItemsCompanion extends UpdateCompanion<MediaItem> {
  final Value<int> id;
  final Value<int> providerAccountId;
  final Value<String> providerType;
  final Value<String> accountKey;
  final Value<String> remoteFileId;
  final Value<String?> parentRemoteFolderId;
  final Value<String> name;
  final Value<String> mediaType;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<DateTime?> captureTime;
  final Value<DateTime> modifiedTime;
  final Value<String?> remoteVersion;
  final Value<String?> checksum;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> durationMs;
  final Value<String?> containerFormat;
  final Value<String?> videoCodec;
  final Value<String?> audioCodec;
  final Value<String?> originalMimeType;
  final Value<String?> previewPath;
  final Value<MediaStatus> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MediaItemsCompanion({
    this.id = const Value.absent(),
    this.providerAccountId = const Value.absent(),
    this.providerType = const Value.absent(),
    this.accountKey = const Value.absent(),
    this.remoteFileId = const Value.absent(),
    this.parentRemoteFolderId = const Value.absent(),
    this.name = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.captureTime = const Value.absent(),
    this.modifiedTime = const Value.absent(),
    this.remoteVersion = const Value.absent(),
    this.checksum = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.containerFormat = const Value.absent(),
    this.videoCodec = const Value.absent(),
    this.audioCodec = const Value.absent(),
    this.originalMimeType = const Value.absent(),
    this.previewPath = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    this.id = const Value.absent(),
    required int providerAccountId,
    required String providerType,
    required String accountKey,
    required String remoteFileId,
    this.parentRemoteFolderId = const Value.absent(),
    required String name,
    required String mediaType,
    required String mimeType,
    required int sizeBytes,
    this.captureTime = const Value.absent(),
    required DateTime modifiedTime,
    this.remoteVersion = const Value.absent(),
    this.checksum = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.containerFormat = const Value.absent(),
    this.videoCodec = const Value.absent(),
    this.audioCodec = const Value.absent(),
    this.originalMimeType = const Value.absent(),
    this.previewPath = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : providerAccountId = Value(providerAccountId),
       providerType = Value(providerType),
       accountKey = Value(accountKey),
       remoteFileId = Value(remoteFileId),
       name = Value(name),
       mediaType = Value(mediaType),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       modifiedTime = Value(modifiedTime),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MediaItem> custom({
    Expression<int>? id,
    Expression<int>? providerAccountId,
    Expression<String>? providerType,
    Expression<String>? accountKey,
    Expression<String>? remoteFileId,
    Expression<String>? parentRemoteFolderId,
    Expression<String>? name,
    Expression<String>? mediaType,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<DateTime>? captureTime,
    Expression<DateTime>? modifiedTime,
    Expression<String>? remoteVersion,
    Expression<String>? checksum,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? durationMs,
    Expression<String>? containerFormat,
    Expression<String>? videoCodec,
    Expression<String>? audioCodec,
    Expression<String>? originalMimeType,
    Expression<String>? previewPath,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerAccountId != null) 'provider_account_id': providerAccountId,
      if (providerType != null) 'provider_type': providerType,
      if (accountKey != null) 'account_key': accountKey,
      if (remoteFileId != null) 'remote_file_id': remoteFileId,
      if (parentRemoteFolderId != null)
        'parent_remote_folder_id': parentRemoteFolderId,
      if (name != null) 'name': name,
      if (mediaType != null) 'media_type': mediaType,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (captureTime != null) 'capture_time': captureTime,
      if (modifiedTime != null) 'modified_time': modifiedTime,
      if (remoteVersion != null) 'remote_version': remoteVersion,
      if (checksum != null) 'checksum': checksum,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (durationMs != null) 'duration_ms': durationMs,
      if (containerFormat != null) 'container_format': containerFormat,
      if (videoCodec != null) 'video_codec': videoCodec,
      if (audioCodec != null) 'audio_codec': audioCodec,
      if (originalMimeType != null) 'original_mime_type': originalMimeType,
      if (previewPath != null) 'preview_path': previewPath,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MediaItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? providerAccountId,
    Value<String>? providerType,
    Value<String>? accountKey,
    Value<String>? remoteFileId,
    Value<String?>? parentRemoteFolderId,
    Value<String>? name,
    Value<String>? mediaType,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<DateTime?>? captureTime,
    Value<DateTime>? modifiedTime,
    Value<String?>? remoteVersion,
    Value<String?>? checksum,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? durationMs,
    Value<String?>? containerFormat,
    Value<String?>? videoCodec,
    Value<String?>? audioCodec,
    Value<String?>? originalMimeType,
    Value<String?>? previewPath,
    Value<MediaStatus>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MediaItemsCompanion(
      id: id ?? this.id,
      providerAccountId: providerAccountId ?? this.providerAccountId,
      providerType: providerType ?? this.providerType,
      accountKey: accountKey ?? this.accountKey,
      remoteFileId: remoteFileId ?? this.remoteFileId,
      parentRemoteFolderId: parentRemoteFolderId ?? this.parentRemoteFolderId,
      name: name ?? this.name,
      mediaType: mediaType ?? this.mediaType,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      captureTime: captureTime ?? this.captureTime,
      modifiedTime: modifiedTime ?? this.modifiedTime,
      remoteVersion: remoteVersion ?? this.remoteVersion,
      checksum: checksum ?? this.checksum,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: durationMs ?? this.durationMs,
      containerFormat: containerFormat ?? this.containerFormat,
      videoCodec: videoCodec ?? this.videoCodec,
      audioCodec: audioCodec ?? this.audioCodec,
      originalMimeType: originalMimeType ?? this.originalMimeType,
      previewPath: previewPath ?? this.previewPath,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (providerAccountId.present) {
      map['provider_account_id'] = Variable<int>(providerAccountId.value);
    }
    if (providerType.present) {
      map['provider_type'] = Variable<String>(providerType.value);
    }
    if (accountKey.present) {
      map['account_key'] = Variable<String>(accountKey.value);
    }
    if (remoteFileId.present) {
      map['remote_file_id'] = Variable<String>(remoteFileId.value);
    }
    if (parentRemoteFolderId.present) {
      map['parent_remote_folder_id'] = Variable<String>(
        parentRemoteFolderId.value,
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (captureTime.present) {
      map['capture_time'] = Variable<DateTime>(captureTime.value);
    }
    if (modifiedTime.present) {
      map['modified_time'] = Variable<DateTime>(modifiedTime.value);
    }
    if (remoteVersion.present) {
      map['remote_version'] = Variable<String>(remoteVersion.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (containerFormat.present) {
      map['container_format'] = Variable<String>(containerFormat.value);
    }
    if (videoCodec.present) {
      map['video_codec'] = Variable<String>(videoCodec.value);
    }
    if (audioCodec.present) {
      map['audio_codec'] = Variable<String>(audioCodec.value);
    }
    if (originalMimeType.present) {
      map['original_mime_type'] = Variable<String>(originalMimeType.value);
    }
    if (previewPath.present) {
      map['preview_path'] = Variable<String>(previewPath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $MediaItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('providerAccountId: $providerAccountId, ')
          ..write('providerType: $providerType, ')
          ..write('accountKey: $accountKey, ')
          ..write('remoteFileId: $remoteFileId, ')
          ..write('parentRemoteFolderId: $parentRemoteFolderId, ')
          ..write('name: $name, ')
          ..write('mediaType: $mediaType, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('captureTime: $captureTime, ')
          ..write('modifiedTime: $modifiedTime, ')
          ..write('remoteVersion: $remoteVersion, ')
          ..write('checksum: $checksum, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('containerFormat: $containerFormat, ')
          ..write('videoCodec: $videoCodec, ')
          ..write('audioCodec: $audioCodec, ')
          ..write('originalMimeType: $originalMimeType, ')
          ..write('previewPath: $previewPath, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncRunsTable extends SyncRuns with TableInfo<$SyncRunsTable, SyncRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncTrigger, String> trigger =
      GeneratedColumn<String>(
        'trigger',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncTrigger>($SyncRunsTable.$convertertrigger);
  @override
  late final GeneratedColumnWithTypeConverter<SyncRunStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncRunStatus>($SyncRunsTable.$converterstatus);
  static const VerificationMeta _foundCountMeta = const VerificationMeta(
    'foundCount',
  );
  @override
  late final GeneratedColumn<int> foundCount = GeneratedColumn<int>(
    'found_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _addedCountMeta = const VerificationMeta(
    'addedCount',
  );
  @override
  late final GeneratedColumn<int> addedCount = GeneratedColumn<int>(
    'added_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedCountMeta = const VerificationMeta(
    'updatedCount',
  );
  @override
  late final GeneratedColumn<int> updatedCount = GeneratedColumn<int>(
    'updated_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deletedCountMeta = const VerificationMeta(
    'deletedCount',
  );
  @override
  late final GeneratedColumn<int> deletedCount = GeneratedColumn<int>(
    'deleted_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _previewCreatedCountMeta =
      const VerificationMeta('previewCreatedCount');
  @override
  late final GeneratedColumn<int> previewCreatedCount = GeneratedColumn<int>(
    'preview_created_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _previewDeletedCountMeta =
      const VerificationMeta('previewDeletedCount');
  @override
  late final GeneratedColumn<int> previewDeletedCount = GeneratedColumn<int>(
    'preview_deleted_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorCountMeta = const VerificationMeta(
    'errorCount',
  );
  @override
  late final GeneratedColumn<int> errorCount = GeneratedColumn<int>(
    'error_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    finishedAt,
    trigger,
    status,
    foundCount,
    addedCount,
    updatedCount,
    deletedCount,
    previewCreatedCount,
    previewDeletedCount,
    errorCount,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('found_count')) {
      context.handle(
        _foundCountMeta,
        foundCount.isAcceptableOrUnknown(data['found_count']!, _foundCountMeta),
      );
    }
    if (data.containsKey('added_count')) {
      context.handle(
        _addedCountMeta,
        addedCount.isAcceptableOrUnknown(data['added_count']!, _addedCountMeta),
      );
    }
    if (data.containsKey('updated_count')) {
      context.handle(
        _updatedCountMeta,
        updatedCount.isAcceptableOrUnknown(
          data['updated_count']!,
          _updatedCountMeta,
        ),
      );
    }
    if (data.containsKey('deleted_count')) {
      context.handle(
        _deletedCountMeta,
        deletedCount.isAcceptableOrUnknown(
          data['deleted_count']!,
          _deletedCountMeta,
        ),
      );
    }
    if (data.containsKey('preview_created_count')) {
      context.handle(
        _previewCreatedCountMeta,
        previewCreatedCount.isAcceptableOrUnknown(
          data['preview_created_count']!,
          _previewCreatedCountMeta,
        ),
      );
    }
    if (data.containsKey('preview_deleted_count')) {
      context.handle(
        _previewDeletedCountMeta,
        previewDeletedCount.isAcceptableOrUnknown(
          data['preview_deleted_count']!,
          _previewDeletedCountMeta,
        ),
      );
    }
    if (data.containsKey('error_count')) {
      context.handle(
        _errorCountMeta,
        errorCount.isAcceptableOrUnknown(data['error_count']!, _errorCountMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncRun(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      trigger: $SyncRunsTable.$convertertrigger.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trigger'],
        )!,
      ),
      status: $SyncRunsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      foundCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}found_count'],
      )!,
      addedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_count'],
      )!,
      updatedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_count'],
      )!,
      deletedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_count'],
      )!,
      previewCreatedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preview_created_count'],
      )!,
      previewDeletedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preview_deleted_count'],
      )!,
      errorCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_count'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $SyncRunsTable createAlias(String alias) {
    return $SyncRunsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncTrigger, String, String> $convertertrigger =
      const EnumNameConverter<SyncTrigger>(SyncTrigger.values);
  static JsonTypeConverter2<SyncRunStatus, String, String> $converterstatus =
      const EnumNameConverter<SyncRunStatus>(SyncRunStatus.values);
}

class SyncRun extends DataClass implements Insertable<SyncRun> {
  final int id;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final SyncTrigger trigger;
  final SyncRunStatus status;
  final int foundCount;
  final int addedCount;
  final int updatedCount;
  final int deletedCount;
  final int previewCreatedCount;
  final int previewDeletedCount;
  final int errorCount;
  final String? errorMessage;
  const SyncRun({
    required this.id,
    required this.startedAt,
    this.finishedAt,
    required this.trigger,
    required this.status,
    required this.foundCount,
    required this.addedCount,
    required this.updatedCount,
    required this.deletedCount,
    required this.previewCreatedCount,
    required this.previewDeletedCount,
    required this.errorCount,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    {
      map['trigger'] = Variable<String>(
        $SyncRunsTable.$convertertrigger.toSql(trigger),
      );
    }
    {
      map['status'] = Variable<String>(
        $SyncRunsTable.$converterstatus.toSql(status),
      );
    }
    map['found_count'] = Variable<int>(foundCount);
    map['added_count'] = Variable<int>(addedCount);
    map['updated_count'] = Variable<int>(updatedCount);
    map['deleted_count'] = Variable<int>(deletedCount);
    map['preview_created_count'] = Variable<int>(previewCreatedCount);
    map['preview_deleted_count'] = Variable<int>(previewDeletedCount);
    map['error_count'] = Variable<int>(errorCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncRunsCompanion toCompanion(bool nullToAbsent) {
    return SyncRunsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      trigger: Value(trigger),
      status: Value(status),
      foundCount: Value(foundCount),
      addedCount: Value(addedCount),
      updatedCount: Value(updatedCount),
      deletedCount: Value(deletedCount),
      previewCreatedCount: Value(previewCreatedCount),
      previewDeletedCount: Value(previewDeletedCount),
      errorCount: Value(errorCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncRun(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      trigger: $SyncRunsTable.$convertertrigger.fromJson(
        serializer.fromJson<String>(json['trigger']),
      ),
      status: $SyncRunsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      foundCount: serializer.fromJson<int>(json['foundCount']),
      addedCount: serializer.fromJson<int>(json['addedCount']),
      updatedCount: serializer.fromJson<int>(json['updatedCount']),
      deletedCount: serializer.fromJson<int>(json['deletedCount']),
      previewCreatedCount: serializer.fromJson<int>(
        json['previewCreatedCount'],
      ),
      previewDeletedCount: serializer.fromJson<int>(
        json['previewDeletedCount'],
      ),
      errorCount: serializer.fromJson<int>(json['errorCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'trigger': serializer.toJson<String>(
        $SyncRunsTable.$convertertrigger.toJson(trigger),
      ),
      'status': serializer.toJson<String>(
        $SyncRunsTable.$converterstatus.toJson(status),
      ),
      'foundCount': serializer.toJson<int>(foundCount),
      'addedCount': serializer.toJson<int>(addedCount),
      'updatedCount': serializer.toJson<int>(updatedCount),
      'deletedCount': serializer.toJson<int>(deletedCount),
      'previewCreatedCount': serializer.toJson<int>(previewCreatedCount),
      'previewDeletedCount': serializer.toJson<int>(previewDeletedCount),
      'errorCount': serializer.toJson<int>(errorCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncRun copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    SyncTrigger? trigger,
    SyncRunStatus? status,
    int? foundCount,
    int? addedCount,
    int? updatedCount,
    int? deletedCount,
    int? previewCreatedCount,
    int? previewDeletedCount,
    int? errorCount,
    Value<String?> errorMessage = const Value.absent(),
  }) => SyncRun(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    trigger: trigger ?? this.trigger,
    status: status ?? this.status,
    foundCount: foundCount ?? this.foundCount,
    addedCount: addedCount ?? this.addedCount,
    updatedCount: updatedCount ?? this.updatedCount,
    deletedCount: deletedCount ?? this.deletedCount,
    previewCreatedCount: previewCreatedCount ?? this.previewCreatedCount,
    previewDeletedCount: previewDeletedCount ?? this.previewDeletedCount,
    errorCount: errorCount ?? this.errorCount,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  SyncRun copyWithCompanion(SyncRunsCompanion data) {
    return SyncRun(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      status: data.status.present ? data.status.value : this.status,
      foundCount: data.foundCount.present
          ? data.foundCount.value
          : this.foundCount,
      addedCount: data.addedCount.present
          ? data.addedCount.value
          : this.addedCount,
      updatedCount: data.updatedCount.present
          ? data.updatedCount.value
          : this.updatedCount,
      deletedCount: data.deletedCount.present
          ? data.deletedCount.value
          : this.deletedCount,
      previewCreatedCount: data.previewCreatedCount.present
          ? data.previewCreatedCount.value
          : this.previewCreatedCount,
      previewDeletedCount: data.previewDeletedCount.present
          ? data.previewDeletedCount.value
          : this.previewDeletedCount,
      errorCount: data.errorCount.present
          ? data.errorCount.value
          : this.errorCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncRun(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('trigger: $trigger, ')
          ..write('status: $status, ')
          ..write('foundCount: $foundCount, ')
          ..write('addedCount: $addedCount, ')
          ..write('updatedCount: $updatedCount, ')
          ..write('deletedCount: $deletedCount, ')
          ..write('previewCreatedCount: $previewCreatedCount, ')
          ..write('previewDeletedCount: $previewDeletedCount, ')
          ..write('errorCount: $errorCount, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    finishedAt,
    trigger,
    status,
    foundCount,
    addedCount,
    updatedCount,
    deletedCount,
    previewCreatedCount,
    previewDeletedCount,
    errorCount,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncRun &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.trigger == this.trigger &&
          other.status == this.status &&
          other.foundCount == this.foundCount &&
          other.addedCount == this.addedCount &&
          other.updatedCount == this.updatedCount &&
          other.deletedCount == this.deletedCount &&
          other.previewCreatedCount == this.previewCreatedCount &&
          other.previewDeletedCount == this.previewDeletedCount &&
          other.errorCount == this.errorCount &&
          other.errorMessage == this.errorMessage);
}

class SyncRunsCompanion extends UpdateCompanion<SyncRun> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<SyncTrigger> trigger;
  final Value<SyncRunStatus> status;
  final Value<int> foundCount;
  final Value<int> addedCount;
  final Value<int> updatedCount;
  final Value<int> deletedCount;
  final Value<int> previewCreatedCount;
  final Value<int> previewDeletedCount;
  final Value<int> errorCount;
  final Value<String?> errorMessage;
  const SyncRunsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.trigger = const Value.absent(),
    this.status = const Value.absent(),
    this.foundCount = const Value.absent(),
    this.addedCount = const Value.absent(),
    this.updatedCount = const Value.absent(),
    this.deletedCount = const Value.absent(),
    this.previewCreatedCount = const Value.absent(),
    this.previewDeletedCount = const Value.absent(),
    this.errorCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  SyncRunsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    required SyncTrigger trigger,
    required SyncRunStatus status,
    this.foundCount = const Value.absent(),
    this.addedCount = const Value.absent(),
    this.updatedCount = const Value.absent(),
    this.deletedCount = const Value.absent(),
    this.previewCreatedCount = const Value.absent(),
    this.previewDeletedCount = const Value.absent(),
    this.errorCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : startedAt = Value(startedAt),
       trigger = Value(trigger),
       status = Value(status);
  static Insertable<SyncRun> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<String>? trigger,
    Expression<String>? status,
    Expression<int>? foundCount,
    Expression<int>? addedCount,
    Expression<int>? updatedCount,
    Expression<int>? deletedCount,
    Expression<int>? previewCreatedCount,
    Expression<int>? previewDeletedCount,
    Expression<int>? errorCount,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (trigger != null) 'trigger': trigger,
      if (status != null) 'status': status,
      if (foundCount != null) 'found_count': foundCount,
      if (addedCount != null) 'added_count': addedCount,
      if (updatedCount != null) 'updated_count': updatedCount,
      if (deletedCount != null) 'deleted_count': deletedCount,
      if (previewCreatedCount != null)
        'preview_created_count': previewCreatedCount,
      if (previewDeletedCount != null)
        'preview_deleted_count': previewDeletedCount,
      if (errorCount != null) 'error_count': errorCount,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  SyncRunsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<SyncTrigger>? trigger,
    Value<SyncRunStatus>? status,
    Value<int>? foundCount,
    Value<int>? addedCount,
    Value<int>? updatedCount,
    Value<int>? deletedCount,
    Value<int>? previewCreatedCount,
    Value<int>? previewDeletedCount,
    Value<int>? errorCount,
    Value<String?>? errorMessage,
  }) {
    return SyncRunsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      trigger: trigger ?? this.trigger,
      status: status ?? this.status,
      foundCount: foundCount ?? this.foundCount,
      addedCount: addedCount ?? this.addedCount,
      updatedCount: updatedCount ?? this.updatedCount,
      deletedCount: deletedCount ?? this.deletedCount,
      previewCreatedCount: previewCreatedCount ?? this.previewCreatedCount,
      previewDeletedCount: previewDeletedCount ?? this.previewDeletedCount,
      errorCount: errorCount ?? this.errorCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(
        $SyncRunsTable.$convertertrigger.toSql(trigger.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SyncRunsTable.$converterstatus.toSql(status.value),
      );
    }
    if (foundCount.present) {
      map['found_count'] = Variable<int>(foundCount.value);
    }
    if (addedCount.present) {
      map['added_count'] = Variable<int>(addedCount.value);
    }
    if (updatedCount.present) {
      map['updated_count'] = Variable<int>(updatedCount.value);
    }
    if (deletedCount.present) {
      map['deleted_count'] = Variable<int>(deletedCount.value);
    }
    if (previewCreatedCount.present) {
      map['preview_created_count'] = Variable<int>(previewCreatedCount.value);
    }
    if (previewDeletedCount.present) {
      map['preview_deleted_count'] = Variable<int>(previewDeletedCount.value);
    }
    if (errorCount.present) {
      map['error_count'] = Variable<int>(errorCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncRunsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('trigger: $trigger, ')
          ..write('status: $status, ')
          ..write('foundCount: $foundCount, ')
          ..write('addedCount: $addedCount, ')
          ..write('updatedCount: $updatedCount, ')
          ..write('deletedCount: $deletedCount, ')
          ..write('previewCreatedCount: $previewCreatedCount, ')
          ..write('previewDeletedCount: $previewDeletedCount, ')
          ..write('errorCount: $errorCount, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $PairingSessionsTable extends PairingSessions
    with TableInfo<$PairingSessionsTable, PairingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PairingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nonceMeta = const VerificationMeta('nonce');
  @override
  late final GeneratedColumn<String> nonce = GeneratedColumn<String>(
    'nonce',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tvPublicKeyMeta = const VerificationMeta(
    'tvPublicKey',
  );
  @override
  late final GeneratedColumn<String> tvPublicKey = GeneratedColumn<String>(
    'tv_public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usedAtMeta = const VerificationMeta('usedAt');
  @override
  late final GeneratedColumn<DateTime> usedAt = GeneratedColumn<DateTime>(
    'used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    nonce,
    tvPublicKey,
    expiresAt,
    usedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pairing_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PairingSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('nonce')) {
      context.handle(
        _nonceMeta,
        nonce.isAcceptableOrUnknown(data['nonce']!, _nonceMeta),
      );
    } else if (isInserting) {
      context.missing(_nonceMeta);
    }
    if (data.containsKey('tv_public_key')) {
      context.handle(
        _tvPublicKeyMeta,
        tvPublicKey.isAcceptableOrUnknown(
          data['tv_public_key']!,
          _tvPublicKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tvPublicKeyMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('used_at')) {
      context.handle(
        _usedAtMeta,
        usedAt.isAcceptableOrUnknown(data['used_at']!, _usedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessionId},
  ];
  @override
  PairingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PairingSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      nonce: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nonce'],
      )!,
      tvPublicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tv_public_key'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      usedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}used_at'],
      ),
    );
  }

  @override
  $PairingSessionsTable createAlias(String alias) {
    return $PairingSessionsTable(attachedDatabase, alias);
  }
}

class PairingSession extends DataClass implements Insertable<PairingSession> {
  final int id;
  final String sessionId;
  final String nonce;
  final String tvPublicKey;
  final DateTime expiresAt;
  final DateTime? usedAt;
  const PairingSession({
    required this.id,
    required this.sessionId,
    required this.nonce,
    required this.tvPublicKey,
    required this.expiresAt,
    this.usedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['nonce'] = Variable<String>(nonce);
    map['tv_public_key'] = Variable<String>(tvPublicKey);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    if (!nullToAbsent || usedAt != null) {
      map['used_at'] = Variable<DateTime>(usedAt);
    }
    return map;
  }

  PairingSessionsCompanion toCompanion(bool nullToAbsent) {
    return PairingSessionsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      nonce: Value(nonce),
      tvPublicKey: Value(tvPublicKey),
      expiresAt: Value(expiresAt),
      usedAt: usedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(usedAt),
    );
  }

  factory PairingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PairingSession(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      nonce: serializer.fromJson<String>(json['nonce']),
      tvPublicKey: serializer.fromJson<String>(json['tvPublicKey']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      usedAt: serializer.fromJson<DateTime?>(json['usedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'nonce': serializer.toJson<String>(nonce),
      'tvPublicKey': serializer.toJson<String>(tvPublicKey),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'usedAt': serializer.toJson<DateTime?>(usedAt),
    };
  }

  PairingSession copyWith({
    int? id,
    String? sessionId,
    String? nonce,
    String? tvPublicKey,
    DateTime? expiresAt,
    Value<DateTime?> usedAt = const Value.absent(),
  }) => PairingSession(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    nonce: nonce ?? this.nonce,
    tvPublicKey: tvPublicKey ?? this.tvPublicKey,
    expiresAt: expiresAt ?? this.expiresAt,
    usedAt: usedAt.present ? usedAt.value : this.usedAt,
  );
  PairingSession copyWithCompanion(PairingSessionsCompanion data) {
    return PairingSession(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      nonce: data.nonce.present ? data.nonce.value : this.nonce,
      tvPublicKey: data.tvPublicKey.present
          ? data.tvPublicKey.value
          : this.tvPublicKey,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      usedAt: data.usedAt.present ? data.usedAt.value : this.usedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PairingSession(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('nonce: $nonce, ')
          ..write('tvPublicKey: $tvPublicKey, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('usedAt: $usedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, nonce, tvPublicKey, expiresAt, usedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PairingSession &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.nonce == this.nonce &&
          other.tvPublicKey == this.tvPublicKey &&
          other.expiresAt == this.expiresAt &&
          other.usedAt == this.usedAt);
}

class PairingSessionsCompanion extends UpdateCompanion<PairingSession> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<String> nonce;
  final Value<String> tvPublicKey;
  final Value<DateTime> expiresAt;
  final Value<DateTime?> usedAt;
  const PairingSessionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.nonce = const Value.absent(),
    this.tvPublicKey = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.usedAt = const Value.absent(),
  });
  PairingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required String nonce,
    required String tvPublicKey,
    required DateTime expiresAt,
    this.usedAt = const Value.absent(),
  }) : sessionId = Value(sessionId),
       nonce = Value(nonce),
       tvPublicKey = Value(tvPublicKey),
       expiresAt = Value(expiresAt);
  static Insertable<PairingSession> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<String>? nonce,
    Expression<String>? tvPublicKey,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? usedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (nonce != null) 'nonce': nonce,
      if (tvPublicKey != null) 'tv_public_key': tvPublicKey,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (usedAt != null) 'used_at': usedAt,
    });
  }

  PairingSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<String>? nonce,
    Value<String>? tvPublicKey,
    Value<DateTime>? expiresAt,
    Value<DateTime?>? usedAt,
  }) {
    return PairingSessionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      nonce: nonce ?? this.nonce,
      tvPublicKey: tvPublicKey ?? this.tvPublicKey,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (nonce.present) {
      map['nonce'] = Variable<String>(nonce.value);
    }
    if (tvPublicKey.present) {
      map['tv_public_key'] = Variable<String>(tvPublicKey.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (usedAt.present) {
      map['used_at'] = Variable<DateTime>(usedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PairingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('nonce: $nonce, ')
          ..write('tvPublicKey: $tvPublicKey, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('usedAt: $usedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProviderAccountsTable providerAccounts = $ProviderAccountsTable(
    this,
  );
  late final $CredentialsTable credentials = $CredentialsTable(this);
  late final $FolderConfigsTable folderConfigs = $FolderConfigsTable(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  late final $SyncRunsTable syncRuns = $SyncRunsTable(this);
  late final $PairingSessionsTable pairingSessions = $PairingSessionsTable(
    this,
  );
  late final Index idxMediaCaptureTime = Index(
    'idx_media_capture_time',
    'CREATE INDEX idx_media_capture_time ON media_items (capture_time)',
  );
  late final Index idxMediaTypeTime = Index(
    'idx_media_type_time',
    'CREATE INDEX idx_media_type_time ON media_items (media_type, capture_time)',
  );
  late final AppDao appDao = AppDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    providerAccounts,
    credentials,
    folderConfigs,
    mediaItems,
    syncRuns,
    pairingSessions,
    idxMediaCaptureTime,
    idxMediaTypeTime,
  ];
}

typedef $$ProviderAccountsTableCreateCompanionBuilder =
    ProviderAccountsCompanion Function({
      Value<int> id,
      required String providerType,
      required String accountId,
      Value<String> displayName,
      Value<AccountStatus> status,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> lastAuthenticatedAt,
      Value<DateTime?> lastSyncAt,
      Value<String?> lastSyncError,
    });
typedef $$ProviderAccountsTableUpdateCompanionBuilder =
    ProviderAccountsCompanion Function({
      Value<int> id,
      Value<String> providerType,
      Value<String> accountId,
      Value<String> displayName,
      Value<AccountStatus> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastAuthenticatedAt,
      Value<DateTime?> lastSyncAt,
      Value<String?> lastSyncError,
    });

class $$ProviderAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $ProviderAccountsTable> {
  $$ProviderAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountStatus, AccountStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAuthenticatedAt => $composableBuilder(
    column: $table.lastAuthenticatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProviderAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProviderAccountsTable> {
  $$ProviderAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAuthenticatedAt => $composableBuilder(
    column: $table.lastAuthenticatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProviderAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProviderAccountsTable> {
  $$ProviderAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AccountStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAuthenticatedAt => $composableBuilder(
    column: $table.lastAuthenticatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncError => $composableBuilder(
    column: $table.lastSyncError,
    builder: (column) => column,
  );
}

class $$ProviderAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProviderAccountsTable,
          ProviderAccount,
          $$ProviderAccountsTableFilterComposer,
          $$ProviderAccountsTableOrderingComposer,
          $$ProviderAccountsTableAnnotationComposer,
          $$ProviderAccountsTableCreateCompanionBuilder,
          $$ProviderAccountsTableUpdateCompanionBuilder,
          (
            ProviderAccount,
            BaseReferences<
              _$AppDatabase,
              $ProviderAccountsTable,
              ProviderAccount
            >,
          ),
          ProviderAccount,
          PrefetchHooks Function()
        > {
  $$ProviderAccountsTableTableManager(
    _$AppDatabase db,
    $ProviderAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProviderAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> providerType = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<AccountStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastAuthenticatedAt = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
              }) => ProviderAccountsCompanion(
                id: id,
                providerType: providerType,
                accountId: accountId,
                displayName: displayName,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastAuthenticatedAt: lastAuthenticatedAt,
                lastSyncAt: lastSyncAt,
                lastSyncError: lastSyncError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String providerType,
                required String accountId,
                Value<String> displayName = const Value.absent(),
                Value<AccountStatus> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> lastAuthenticatedAt = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> lastSyncError = const Value.absent(),
              }) => ProviderAccountsCompanion.insert(
                id: id,
                providerType: providerType,
                accountId: accountId,
                displayName: displayName,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastAuthenticatedAt: lastAuthenticatedAt,
                lastSyncAt: lastSyncAt,
                lastSyncError: lastSyncError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProviderAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProviderAccountsTable,
      ProviderAccount,
      $$ProviderAccountsTableFilterComposer,
      $$ProviderAccountsTableOrderingComposer,
      $$ProviderAccountsTableAnnotationComposer,
      $$ProviderAccountsTableCreateCompanionBuilder,
      $$ProviderAccountsTableUpdateCompanionBuilder,
      (
        ProviderAccount,
        BaseReferences<_$AppDatabase, $ProviderAccountsTable, ProviderAccount>,
      ),
      ProviderAccount,
      PrefetchHooks Function()
    >;
typedef $$CredentialsTableCreateCompanionBuilder =
    CredentialsCompanion Function({
      Value<int> providerAccountId,
      required String accessTokenEncrypted,
      Value<String?> refreshTokenEncrypted,
      required DateTime expiresAt,
      Value<String> tokenType,
      required DateTime updatedAt,
    });
typedef $$CredentialsTableUpdateCompanionBuilder =
    CredentialsCompanion Function({
      Value<int> providerAccountId,
      Value<String> accessTokenEncrypted,
      Value<String?> refreshTokenEncrypted,
      Value<DateTime> expiresAt,
      Value<String> tokenType,
      Value<DateTime> updatedAt,
    });

class $$CredentialsTableFilterComposer
    extends Composer<_$AppDatabase, $CredentialsTable> {
  $$CredentialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessTokenEncrypted => $composableBuilder(
    column: $table.accessTokenEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refreshTokenEncrypted => $composableBuilder(
    column: $table.refreshTokenEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenType => $composableBuilder(
    column: $table.tokenType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CredentialsTableOrderingComposer
    extends Composer<_$AppDatabase, $CredentialsTable> {
  $$CredentialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessTokenEncrypted => $composableBuilder(
    column: $table.accessTokenEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refreshTokenEncrypted => $composableBuilder(
    column: $table.refreshTokenEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenType => $composableBuilder(
    column: $table.tokenType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CredentialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CredentialsTable> {
  $$CredentialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accessTokenEncrypted => $composableBuilder(
    column: $table.accessTokenEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refreshTokenEncrypted => $composableBuilder(
    column: $table.refreshTokenEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get tokenType =>
      $composableBuilder(column: $table.tokenType, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CredentialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CredentialsTable,
          Credential,
          $$CredentialsTableFilterComposer,
          $$CredentialsTableOrderingComposer,
          $$CredentialsTableAnnotationComposer,
          $$CredentialsTableCreateCompanionBuilder,
          $$CredentialsTableUpdateCompanionBuilder,
          (
            Credential,
            BaseReferences<_$AppDatabase, $CredentialsTable, Credential>,
          ),
          Credential,
          PrefetchHooks Function()
        > {
  $$CredentialsTableTableManager(_$AppDatabase db, $CredentialsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CredentialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CredentialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CredentialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> providerAccountId = const Value.absent(),
                Value<String> accessTokenEncrypted = const Value.absent(),
                Value<String?> refreshTokenEncrypted = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<String> tokenType = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CredentialsCompanion(
                providerAccountId: providerAccountId,
                accessTokenEncrypted: accessTokenEncrypted,
                refreshTokenEncrypted: refreshTokenEncrypted,
                expiresAt: expiresAt,
                tokenType: tokenType,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> providerAccountId = const Value.absent(),
                required String accessTokenEncrypted,
                Value<String?> refreshTokenEncrypted = const Value.absent(),
                required DateTime expiresAt,
                Value<String> tokenType = const Value.absent(),
                required DateTime updatedAt,
              }) => CredentialsCompanion.insert(
                providerAccountId: providerAccountId,
                accessTokenEncrypted: accessTokenEncrypted,
                refreshTokenEncrypted: refreshTokenEncrypted,
                expiresAt: expiresAt,
                tokenType: tokenType,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CredentialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CredentialsTable,
      Credential,
      $$CredentialsTableFilterComposer,
      $$CredentialsTableOrderingComposer,
      $$CredentialsTableAnnotationComposer,
      $$CredentialsTableCreateCompanionBuilder,
      $$CredentialsTableUpdateCompanionBuilder,
      (
        Credential,
        BaseReferences<_$AppDatabase, $CredentialsTable, Credential>,
      ),
      Credential,
      PrefetchHooks Function()
    >;
typedef $$FolderConfigsTableCreateCompanionBuilder =
    FolderConfigsCompanion Function({
      Value<int> id,
      required int providerAccountId,
      required String remoteFolderId,
      required String folderPathSnapshot,
      required String folderName,
      Value<bool> enabled,
      Value<bool> recursive,
      Value<FolderConfigStatus> status,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$FolderConfigsTableUpdateCompanionBuilder =
    FolderConfigsCompanion Function({
      Value<int> id,
      Value<int> providerAccountId,
      Value<String> remoteFolderId,
      Value<String> folderPathSnapshot,
      Value<String> folderName,
      Value<bool> enabled,
      Value<bool> recursive,
      Value<FolderConfigStatus> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$FolderConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $FolderConfigsTable> {
  $$FolderConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteFolderId => $composableBuilder(
    column: $table.remoteFolderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderPathSnapshot => $composableBuilder(
    column: $table.folderPathSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recursive => $composableBuilder(
    column: $table.recursive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FolderConfigStatus, FolderConfigStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FolderConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $FolderConfigsTable> {
  $$FolderConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteFolderId => $composableBuilder(
    column: $table.remoteFolderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderPathSnapshot => $composableBuilder(
    column: $table.folderPathSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recursive => $composableBuilder(
    column: $table.recursive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FolderConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FolderConfigsTable> {
  $$FolderConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteFolderId => $composableBuilder(
    column: $table.remoteFolderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get folderPathSnapshot => $composableBuilder(
    column: $table.folderPathSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<bool> get recursive =>
      $composableBuilder(column: $table.recursive, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FolderConfigStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FolderConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FolderConfigsTable,
          FolderConfig,
          $$FolderConfigsTableFilterComposer,
          $$FolderConfigsTableOrderingComposer,
          $$FolderConfigsTableAnnotationComposer,
          $$FolderConfigsTableCreateCompanionBuilder,
          $$FolderConfigsTableUpdateCompanionBuilder,
          (
            FolderConfig,
            BaseReferences<_$AppDatabase, $FolderConfigsTable, FolderConfig>,
          ),
          FolderConfig,
          PrefetchHooks Function()
        > {
  $$FolderConfigsTableTableManager(_$AppDatabase db, $FolderConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FolderConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FolderConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FolderConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> providerAccountId = const Value.absent(),
                Value<String> remoteFolderId = const Value.absent(),
                Value<String> folderPathSnapshot = const Value.absent(),
                Value<String> folderName = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> recursive = const Value.absent(),
                Value<FolderConfigStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FolderConfigsCompanion(
                id: id,
                providerAccountId: providerAccountId,
                remoteFolderId: remoteFolderId,
                folderPathSnapshot: folderPathSnapshot,
                folderName: folderName,
                enabled: enabled,
                recursive: recursive,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int providerAccountId,
                required String remoteFolderId,
                required String folderPathSnapshot,
                required String folderName,
                Value<bool> enabled = const Value.absent(),
                Value<bool> recursive = const Value.absent(),
                Value<FolderConfigStatus> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => FolderConfigsCompanion.insert(
                id: id,
                providerAccountId: providerAccountId,
                remoteFolderId: remoteFolderId,
                folderPathSnapshot: folderPathSnapshot,
                folderName: folderName,
                enabled: enabled,
                recursive: recursive,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FolderConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FolderConfigsTable,
      FolderConfig,
      $$FolderConfigsTableFilterComposer,
      $$FolderConfigsTableOrderingComposer,
      $$FolderConfigsTableAnnotationComposer,
      $$FolderConfigsTableCreateCompanionBuilder,
      $$FolderConfigsTableUpdateCompanionBuilder,
      (
        FolderConfig,
        BaseReferences<_$AppDatabase, $FolderConfigsTable, FolderConfig>,
      ),
      FolderConfig,
      PrefetchHooks Function()
    >;
typedef $$MediaItemsTableCreateCompanionBuilder = MediaItemsCompanion Function({
  Value<int> id,
  required int providerAccountId,
  required String providerType,
  required String accountKey,
  required String remoteFileId,
  Value<String?> parentRemoteFolderId,
  required String name,
  required String mediaType,
  required String mimeType,
  required int sizeBytes,
  Value<DateTime?> captureTime,
  required DateTime modifiedTime,
  Value<String?> remoteVersion,
  Value<String?> checksum,
  Value<int?> width,
  Value<int?> height,
  Value<int?> durationMs,
  Value<String?> containerFormat,
  Value<String?> videoCodec,
  Value<String?> audioCodec,
  Value<String?> originalMimeType,
  Value<String?> previewPath,
  Value<MediaStatus> status,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$MediaItemsTableUpdateCompanionBuilder = MediaItemsCompanion Function({
  Value<int> id,
  Value<int> providerAccountId,
  Value<String> providerType,
  Value<String> accountKey,
  Value<String> remoteFileId,
  Value<String?> parentRemoteFolderId,
  Value<String> name,
  Value<String> mediaType,
  Value<String> mimeType,
  Value<int> sizeBytes,
  Value<DateTime?> captureTime,
  Value<DateTime> modifiedTime,
  Value<String?> remoteVersion,
  Value<String?> checksum,
  Value<int?> width,
  Value<int?> height,
  Value<int?> durationMs,
  Value<String?> containerFormat,
  Value<String?> videoCodec,
  Value<String?> audioCodec,
  Value<String?> originalMimeType,
  Value<String?> previewPath,
  Value<MediaStatus> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$MediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteFileId => $composableBuilder(
    column: $table.remoteFileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentRemoteFolderId => $composableBuilder(
    column: $table.parentRemoteFolderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get captureTime => $composableBuilder(
    column: $table.captureTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedTime => $composableBuilder(
    column: $table.modifiedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteVersion => $composableBuilder(
    column: $table.remoteVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get containerFormat => $composableBuilder(
    column: $table.containerFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoCodec => $composableBuilder(
    column: $table.videoCodec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioCodec => $composableBuilder(
    column: $table.audioCodec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalMimeType => $composableBuilder(
    column: $table.originalMimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previewPath => $composableBuilder(
    column: $table.previewPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MediaStatus, MediaStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteFileId => $composableBuilder(
    column: $table.remoteFileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentRemoteFolderId => $composableBuilder(
    column: $table.parentRemoteFolderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get captureTime => $composableBuilder(
    column: $table.captureTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedTime => $composableBuilder(
    column: $table.modifiedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteVersion => $composableBuilder(
    column: $table.remoteVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get containerFormat => $composableBuilder(
    column: $table.containerFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoCodec => $composableBuilder(
    column: $table.videoCodec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioCodec => $composableBuilder(
    column: $table.audioCodec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalMimeType => $composableBuilder(
    column: $table.originalMimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previewPath => $composableBuilder(
    column: $table.previewPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get providerAccountId => $composableBuilder(
    column: $table.providerAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountKey => $composableBuilder(
    column: $table.accountKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteFileId => $composableBuilder(
    column: $table.remoteFileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentRemoteFolderId => $composableBuilder(
    column: $table.parentRemoteFolderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get captureTime => $composableBuilder(
    column: $table.captureTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get modifiedTime => $composableBuilder(
    column: $table.modifiedTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteVersion => $composableBuilder(
    column: $table.remoteVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get containerFormat => $composableBuilder(
    column: $table.containerFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get videoCodec => $composableBuilder(
    column: $table.videoCodec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioCodec => $composableBuilder(
    column: $table.audioCodec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalMimeType => $composableBuilder(
    column: $table.originalMimeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previewPath => $composableBuilder(
    column: $table.previewPath,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MediaStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MediaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaItemsTable,
          MediaItem,
          $$MediaItemsTableFilterComposer,
          $$MediaItemsTableOrderingComposer,
          $$MediaItemsTableAnnotationComposer,
          $$MediaItemsTableCreateCompanionBuilder,
          $$MediaItemsTableUpdateCompanionBuilder,
          (
            MediaItem,
            BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem>,
          ),
          MediaItem,
          PrefetchHooks Function()
        > {
  $$MediaItemsTableTableManager(_$AppDatabase db, $MediaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> providerAccountId = const Value.absent(),
                Value<String> providerType = const Value.absent(),
                Value<String> accountKey = const Value.absent(),
                Value<String> remoteFileId = const Value.absent(),
                Value<String?> parentRemoteFolderId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime?> captureTime = const Value.absent(),
                Value<DateTime> modifiedTime = const Value.absent(),
                Value<String?> remoteVersion = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> containerFormat = const Value.absent(),
                Value<String?> videoCodec = const Value.absent(),
                Value<String?> audioCodec = const Value.absent(),
                Value<String?> originalMimeType = const Value.absent(),
                Value<String?> previewPath = const Value.absent(),
                Value<MediaStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MediaItemsCompanion(
                id: id,
                providerAccountId: providerAccountId,
                providerType: providerType,
                accountKey: accountKey,
                remoteFileId: remoteFileId,
                parentRemoteFolderId: parentRemoteFolderId,
                name: name,
                mediaType: mediaType,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                captureTime: captureTime,
                modifiedTime: modifiedTime,
                remoteVersion: remoteVersion,
                checksum: checksum,
                width: width,
                height: height,
                durationMs: durationMs,
                containerFormat: containerFormat,
                videoCodec: videoCodec,
                audioCodec: audioCodec,
                originalMimeType: originalMimeType,
                previewPath: previewPath,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int providerAccountId,
                required String providerType,
                required String accountKey,
                required String remoteFileId,
                Value<String?> parentRemoteFolderId = const Value.absent(),
                required String name,
                required String mediaType,
                required String mimeType,
                required int sizeBytes,
                Value<DateTime?> captureTime = const Value.absent(),
                required DateTime modifiedTime,
                Value<String?> remoteVersion = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> containerFormat = const Value.absent(),
                Value<String?> videoCodec = const Value.absent(),
                Value<String?> audioCodec = const Value.absent(),
                Value<String?> originalMimeType = const Value.absent(),
                Value<String?> previewPath = const Value.absent(),
                Value<MediaStatus> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => MediaItemsCompanion.insert(
                id: id,
                providerAccountId: providerAccountId,
                providerType: providerType,
                accountKey: accountKey,
                remoteFileId: remoteFileId,
                parentRemoteFolderId: parentRemoteFolderId,
                name: name,
                mediaType: mediaType,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                captureTime: captureTime,
                modifiedTime: modifiedTime,
                remoteVersion: remoteVersion,
                checksum: checksum,
                width: width,
                height: height,
                durationMs: durationMs,
                containerFormat: containerFormat,
                videoCodec: videoCodec,
                audioCodec: audioCodec,
                originalMimeType: originalMimeType,
                previewPath: previewPath,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaItemsTable,
      MediaItem,
      $$MediaItemsTableFilterComposer,
      $$MediaItemsTableOrderingComposer,
      $$MediaItemsTableAnnotationComposer,
      $$MediaItemsTableCreateCompanionBuilder,
      $$MediaItemsTableUpdateCompanionBuilder,
      (MediaItem, BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem>),
      MediaItem,
      PrefetchHooks Function()
    >;
typedef $$SyncRunsTableCreateCompanionBuilder = SyncRunsCompanion Function({
  Value<int> id,
  required DateTime startedAt,
  Value<DateTime?> finishedAt,
  required SyncTrigger trigger,
  required SyncRunStatus status,
  Value<int> foundCount,
  Value<int> addedCount,
  Value<int> updatedCount,
  Value<int> deletedCount,
  Value<int> previewCreatedCount,
  Value<int> previewDeletedCount,
  Value<int> errorCount,
  Value<String?> errorMessage,
});
typedef $$SyncRunsTableUpdateCompanionBuilder = SyncRunsCompanion Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<DateTime?> finishedAt,
  Value<SyncTrigger> trigger,
  Value<SyncRunStatus> status,
  Value<int> foundCount,
  Value<int> addedCount,
  Value<int> updatedCount,
  Value<int> deletedCount,
  Value<int> previewCreatedCount,
  Value<int> previewDeletedCount,
  Value<int> errorCount,
  Value<String?> errorMessage,
});

class $$SyncRunsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncRunsTable> {
  $$SyncRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncTrigger, SyncTrigger, String>
  get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncRunStatus, SyncRunStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get foundCount => $composableBuilder(
    column: $table.foundCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedCount => $composableBuilder(
    column: $table.addedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedCount => $composableBuilder(
    column: $table.updatedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedCount => $composableBuilder(
    column: $table.deletedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previewCreatedCount => $composableBuilder(
    column: $table.previewCreatedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get previewDeletedCount => $composableBuilder(
    column: $table.previewDeletedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncRunsTable> {
  $$SyncRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get foundCount => $composableBuilder(
    column: $table.foundCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedCount => $composableBuilder(
    column: $table.addedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedCount => $composableBuilder(
    column: $table.updatedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedCount => $composableBuilder(
    column: $table.deletedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previewCreatedCount => $composableBuilder(
    column: $table.previewCreatedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get previewDeletedCount => $composableBuilder(
    column: $table.previewDeletedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncRunsTable> {
  $$SyncRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncTrigger, String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncRunStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get foundCount => $composableBuilder(
    column: $table.foundCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get addedCount => $composableBuilder(
    column: $table.addedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedCount => $composableBuilder(
    column: $table.updatedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedCount => $composableBuilder(
    column: $table.deletedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get previewCreatedCount => $composableBuilder(
    column: $table.previewCreatedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get previewDeletedCount => $composableBuilder(
    column: $table.previewDeletedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$SyncRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncRunsTable,
          SyncRun,
          $$SyncRunsTableFilterComposer,
          $$SyncRunsTableOrderingComposer,
          $$SyncRunsTableAnnotationComposer,
          $$SyncRunsTableCreateCompanionBuilder,
          $$SyncRunsTableUpdateCompanionBuilder,
          (SyncRun, BaseReferences<_$AppDatabase, $SyncRunsTable, SyncRun>),
          SyncRun,
          PrefetchHooks Function()
        > {
  $$SyncRunsTableTableManager(_$AppDatabase db, $SyncRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<SyncTrigger> trigger = const Value.absent(),
                Value<SyncRunStatus> status = const Value.absent(),
                Value<int> foundCount = const Value.absent(),
                Value<int> addedCount = const Value.absent(),
                Value<int> updatedCount = const Value.absent(),
                Value<int> deletedCount = const Value.absent(),
                Value<int> previewCreatedCount = const Value.absent(),
                Value<int> previewDeletedCount = const Value.absent(),
                Value<int> errorCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => SyncRunsCompanion(
                id: id,
                startedAt: startedAt,
                finishedAt: finishedAt,
                trigger: trigger,
                status: status,
                foundCount: foundCount,
                addedCount: addedCount,
                updatedCount: updatedCount,
                deletedCount: deletedCount,
                previewCreatedCount: previewCreatedCount,
                previewDeletedCount: previewDeletedCount,
                errorCount: errorCount,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                required SyncTrigger trigger,
                required SyncRunStatus status,
                Value<int> foundCount = const Value.absent(),
                Value<int> addedCount = const Value.absent(),
                Value<int> updatedCount = const Value.absent(),
                Value<int> deletedCount = const Value.absent(),
                Value<int> previewCreatedCount = const Value.absent(),
                Value<int> previewDeletedCount = const Value.absent(),
                Value<int> errorCount = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => SyncRunsCompanion.insert(
                id: id,
                startedAt: startedAt,
                finishedAt: finishedAt,
                trigger: trigger,
                status: status,
                foundCount: foundCount,
                addedCount: addedCount,
                updatedCount: updatedCount,
                deletedCount: deletedCount,
                previewCreatedCount: previewCreatedCount,
                previewDeletedCount: previewDeletedCount,
                errorCount: errorCount,
                errorMessage: errorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncRunsTable,
      SyncRun,
      $$SyncRunsTableFilterComposer,
      $$SyncRunsTableOrderingComposer,
      $$SyncRunsTableAnnotationComposer,
      $$SyncRunsTableCreateCompanionBuilder,
      $$SyncRunsTableUpdateCompanionBuilder,
      (SyncRun, BaseReferences<_$AppDatabase, $SyncRunsTable, SyncRun>),
      SyncRun,
      PrefetchHooks Function()
    >;
typedef $$PairingSessionsTableCreateCompanionBuilder =
    PairingSessionsCompanion Function({
      Value<int> id,
      required String sessionId,
      required String nonce,
      required String tvPublicKey,
      required DateTime expiresAt,
      Value<DateTime?> usedAt,
    });
typedef $$PairingSessionsTableUpdateCompanionBuilder =
    PairingSessionsCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<String> nonce,
      Value<String> tvPublicKey,
      Value<DateTime> expiresAt,
      Value<DateTime?> usedAt,
    });

class $$PairingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PairingSessionsTable> {
  $$PairingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nonce => $composableBuilder(
    column: $table.nonce,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tvPublicKey => $composableBuilder(
    column: $table.tvPublicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get usedAt => $composableBuilder(
    column: $table.usedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PairingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PairingSessionsTable> {
  $$PairingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nonce => $composableBuilder(
    column: $table.nonce,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tvPublicKey => $composableBuilder(
    column: $table.tvPublicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get usedAt => $composableBuilder(
    column: $table.usedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PairingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PairingSessionsTable> {
  $$PairingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get nonce =>
      $composableBuilder(column: $table.nonce, builder: (column) => column);

  GeneratedColumn<String> get tvPublicKey => $composableBuilder(
    column: $table.tvPublicKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get usedAt =>
      $composableBuilder(column: $table.usedAt, builder: (column) => column);
}

class $$PairingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PairingSessionsTable,
          PairingSession,
          $$PairingSessionsTableFilterComposer,
          $$PairingSessionsTableOrderingComposer,
          $$PairingSessionsTableAnnotationComposer,
          $$PairingSessionsTableCreateCompanionBuilder,
          $$PairingSessionsTableUpdateCompanionBuilder,
          (
            PairingSession,
            BaseReferences<
              _$AppDatabase,
              $PairingSessionsTable,
              PairingSession
            >,
          ),
          PairingSession,
          PrefetchHooks Function()
        > {
  $$PairingSessionsTableTableManager(
    _$AppDatabase db,
    $PairingSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PairingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PairingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PairingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> nonce = const Value.absent(),
                Value<String> tvPublicKey = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<DateTime?> usedAt = const Value.absent(),
              }) => PairingSessionsCompanion(
                id: id,
                sessionId: sessionId,
                nonce: nonce,
                tvPublicKey: tvPublicKey,
                expiresAt: expiresAt,
                usedAt: usedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required String nonce,
                required String tvPublicKey,
                required DateTime expiresAt,
                Value<DateTime?> usedAt = const Value.absent(),
              }) => PairingSessionsCompanion.insert(
                id: id,
                sessionId: sessionId,
                nonce: nonce,
                tvPublicKey: tvPublicKey,
                expiresAt: expiresAt,
                usedAt: usedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PairingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PairingSessionsTable,
      PairingSession,
      $$PairingSessionsTableFilterComposer,
      $$PairingSessionsTableOrderingComposer,
      $$PairingSessionsTableAnnotationComposer,
      $$PairingSessionsTableCreateCompanionBuilder,
      $$PairingSessionsTableUpdateCompanionBuilder,
      (
        PairingSession,
        BaseReferences<_$AppDatabase, $PairingSessionsTable, PairingSession>,
      ),
      PairingSession,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProviderAccountsTableTableManager get providerAccounts =>
      $$ProviderAccountsTableTableManager(_db, _db.providerAccounts);
  $$CredentialsTableTableManager get credentials =>
      $$CredentialsTableTableManager(_db, _db.credentials);
  $$FolderConfigsTableTableManager get folderConfigs =>
      $$FolderConfigsTableTableManager(_db, _db.folderConfigs);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
  $$SyncRunsTableTableManager get syncRuns =>
      $$SyncRunsTableTableManager(_db, _db.syncRuns);
  $$PairingSessionsTableTableManager get pairingSessions =>
      $$PairingSessionsTableTableManager(_db, _db.pairingSessions);
}
