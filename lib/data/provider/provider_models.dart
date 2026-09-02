import 'package:collection/collection.dart';

/// 支持的云盘类型。
enum ProviderType {
  tianyiCloud('TIANYI_CLOUD'),
  cloud115('115_CLOUD');

  const ProviderType(this.wireName);
  final String wireName;

  static ProviderType? fromWire(String? name) =>
      ProviderType.values.firstWhereOrNull((t) => t.wireName == name);

  String get displayName => switch (this) {
    ProviderType.tianyiCloud => '天翼云盘',
    ProviderType.cloud115 => '115 网盘',
  };
}

/// 媒体类型。
enum MediaType {
  image('IMAGE'),
  video('VIDEO');

  const MediaType(this.wireName);
  final String wireName;

  static MediaType? fromWire(String? name) =>
      MediaType.values.firstWhereOrNull((t) => t.wireName == name);

  /// 按扩展名 + MIME 推断（PRD §25.1 magic/extension 一致性由 provider 保证）。
  static MediaType? fromFile(String name, String? mimeType) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic') ||
        lower.endsWith('.heif') ||
        lower.endsWith('.avif') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp') ||
        lower.endsWith('.livp') ||
        (mimeType ?? '').startsWith('image/')) {
      return MediaType.image;
    }
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.3gp') ||
        lower.endsWith('.avi') ||
        (mimeType ?? '').startsWith('video/')) {
      return MediaType.video;
    }
    return null;
  }
}

/// 凭据状态。
enum CredentialState { authenticated, needReauth, unavailable }

/// OAuth 凭据。
class Credentials {
  const Credentials({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.tokenType,
    this.accountId = '',
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  /// 云盘账号唯一标识（同步唯一键组成部分）。
  final String accountId;

  Credentials copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
    String? accountId,
  }) => Credentials(
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    expiresAt: expiresAt ?? this.expiresAt,
    tokenType: tokenType ?? this.tokenType,
    accountId: accountId ?? this.accountId,
  );

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
    'tokenType': tokenType,
    'accountId': accountId,
  };

  factory Credentials.fromJson(Map<String, dynamic> json) => Credentials(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    tokenType: json['tokenType'] as String? ?? 'Bearer',
    accountId: json['accountId'] as String? ?? '',
  );
}

/// 授权结果。
sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  const AuthSuccess(this.credentials);
  final Credentials credentials;
}

class AuthNeedReauth extends AuthResult {
  const AuthNeedReauth();
}

/// 官方开放平台凭证不可用 → Provider 进入 UNAVAILABLE（PRD 实现前置约束）。
class AuthUnavailable extends AuthResult {
  const AuthUnavailable(this.reason);
  final String reason;
}

class AuthFailed extends AuthResult {
  const AuthFailed(this.error);
  final Object error;
}

/// 远端文件夹。
class RemoteFolder {
  const RemoteFolder({required this.id, required this.name, this.parentId});
  final String id;
  final String name;
  final String? parentId;
}

/// 远端媒体文件。
class RemoteMedia {
  const RemoteMedia({
    required this.remoteFileId,
    required this.name,
    required this.mediaType,
    required this.mimeType,
    required this.sizeBytes,
    required this.modifiedTime,
    this.parentFolderId,
    this.captureTime,
    this.remoteVersion,
    this.checksum,
    this.width,
    this.height,
    this.durationMs,
    this.thumbnailUrl,
  });

  final String remoteFileId;
  final String? parentFolderId;
  final String name;
  final MediaType mediaType;
  final String mimeType;
  final int sizeBytes;
  final DateTime? captureTime;
  final DateTime modifiedTime;

  /// 远端版本号（用于增量 diff）。
  final String? remoteVersion;
  final String? checksum;
  final int? width;
  final int? height;
  final int? durationMs;

  /// 云盘提供的缩略图 URL（如有）。
  final String? thumbnailUrl;
}

/// 分页结果。
class RemotePage<T> {
  const RemotePage({required this.items, this.nextCursor});
  final List<T> items;
  final String? nextCursor;
  bool get hasMore => nextCursor?.isNotEmpty ?? false;
}

/// 可播放源（URL 具有时效性，禁止长期持久化）。
class PlayableSource {
  const PlayableSource({required this.url, this.expiresAt});
  final String url;
  final DateTime? expiresAt;
}

/// 原图下载源。
class ImageSource {
  const ImageSource({required this.url, this.expectedSizeBytes});
  final String url;
  final int? expectedSizeBytes;
}
