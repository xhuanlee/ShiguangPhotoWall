import 'package:dio/dio.dart';

import '../../core/error/network_error.dart';
import '../../core/result/result.dart';
import 'oauth/oauth_core.dart';
import 'base_rest_provider.dart';
import 'provider_models.dart';

/// 天翼云盘 Provider（官方天翼云盘开放平台）。
///
/// 端点以官方开放平台当前文档为准（PRD §58）；如与实际授权有差异，
/// 只修改本文件，不改业务层。
class ProviderTianyi extends BaseRestCloudProvider {
  ProviderTianyi({
    required super.dio,
    required super.oauth,
    required super.authorizer,
  });

  static const String defaultAuthorizeUrl = String.fromEnvironment(
    'SGPW_TIANYI_AUTHORIZE_URL',
    defaultValue: 'https://oauth2.21cn.com/open/authorize',
  );
  static const String defaultTokenUrl = String.fromEnvironment(
    'SGPW_TIANYI_TOKEN_URL',
    defaultValue: 'https://oauth2.21cn.com/open/oauth/token',
  );
  static const String defaultApiBase = String.fromEnvironment(
    'SGPW_TIANYI_API_BASE',
    defaultValue: 'https://open.cloud.189.cn/api',
  );

  @override
  ProviderType get type => ProviderType.tianyiCloud;

  @override
  Uri buildAuthorizeUrl(String state, String codeChallenge) =>
      Uri.parse(defaultAuthorizeUrl).replace(
        queryParameters: {
          'response_type': 'code',
          'client_id': oauth.clientId,
          'redirect_uri': oauth.redirectUri,
          'state': state,
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
        },
      );

  @override
  String get tokenEndpoint => defaultTokenUrl;

  @override
  String get apiBase => defaultApiBase;

  @override
  Future<String?> fetchAccountId(Credentials credentials) async {
    try {
      final response = await authGet<Map<String, dynamic>>(
        '$apiBase/user/getUserInfo',
      );
      final data = response.data;
      return data?['account']?.toString() ?? data?['user_id']?.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<List<RemoteFolder>>> listFolders(String? parentFolderId) =>
      guarded(() async {
        final folders = <RemoteFolder>[];
        var pageNum = 1;
        const pageSize = 100;
        while (true) {
          final response = await authGet<Map<String, dynamic>>(
            '$apiBase/file/listFiles',
            query: {
              'folderId': parentFolderId ?? '-11',
              'pageNum': pageNum,
              'pageSize': pageSize,
              'mediaType': 0,
              'iconOption': 5,
            },
          );
          final fileList = _fileList(response.data);
          for (final entry in fileList) {
            final folder = parseFolderEntry(entry);
            if (folder != null) folders.add(folder);
          }
          if (fileList.length < pageSize) break;
          pageNum++;
        }
        return folders;
      });

  @override
  Future<Result<RemotePage<RemoteMedia>>> listMedia(
    String folderId,
    String? cursor,
  ) => guarded(() async {
    final pageNum = int.tryParse(cursor ?? '1') ?? 1;
    const pageSize = 100;
    final response = await authGet<Map<String, dynamic>>(
      '$apiBase/file/listFiles',
      query: {
        'folderId': folderId,
        'pageNum': pageNum,
        'pageSize': pageSize,
        'mediaType': 0,
        'iconOption': 5,
      },
    );
    final fileList = _fileList(response.data);
    final media = <RemoteMedia>[];
    for (final entry in fileList) {
      final item = parseFileEntry(entry, folderId);
      if (item != null) media.add(item);
    }
    return RemotePage(
      items: media,
      nextCursor: fileList.length >= pageSize ? (pageNum + 1).toString() : null,
    );
  });

  @override
  Future<Result<PlayableSource>> getPlayableUrl(String mediaId) async {
    final result = await guarded(() async {
      final response = await authGet<Map<String, dynamic>>(
        '$apiBase/file/getFileDownloadUrl',
        query: {'fileId': mediaId},
      );
      final url = response.data?['fileDownloadUrl'] as String?;
      if (url == null || url.isEmpty) throw const NotFound();
      return url;
    });
    return result.fold(
      ok: (url) => Ok(PlayableSource(url: url)),
      err: (e) => Err(e),
    );
  }

  @override
  Future<Result<ImageSource>> getOriginalImageSource(String mediaId) async {
    final result = await guarded(() async {
      final response = await authGet<Map<String, dynamic>>(
        '$apiBase/file/getFileDownloadUrl',
        query: {'fileId': mediaId},
      );
      final url = response.data?['fileDownloadUrl'] as String?;
      if (url == null || url.isEmpty) throw const NotFound();
      return url;
    });
    return result.fold(
      ok: (url) => Ok(ImageSource(url: url)),
      err: (e) => Err(e),
    );
  }

  // ---- 解析 ---------------------------------------------------------------

  @override
  RemoteFolder? parseFolderEntry(Map<String, dynamic> entry) {
    final isFolder = entry['isFolder'] == true;
    if (!isFolder) return null;
    final id = entry['folderId']?.toString() ?? entry['fileId']?.toString();
    final name = entry['fileName'] as String? ?? entry['name'] as String?;
    if (id == null || name == null) return null;
    return RemoteFolder(
      id: id,
      name: name,
      parentId: entry['parentFolderId']?.toString(),
    );
  }

  @override
  RemoteMedia? parseFileEntry(
    Map<String, dynamic> entry,
    String parentFolderId,
  ) {
    if (entry['isFolder'] == true) return null;
    final id = entry['fileId']?.toString();
    final name = entry['fileName'] as String? ?? entry['name'] as String?;
    if (id == null || name == null) return null;
    final mediaType = MediaType.fromFile(name, entry['mediaType'] as String?);
    if (mediaType == null) return null;
    final size = (entry['fileSize'] as num?)?.toInt() ?? 0;
    return RemoteMedia(
      remoteFileId: id,
      parentFolderId: parentFolderId,
      name: name,
      mediaType: mediaType,
      mimeType: entry['mediaType'] as String? ?? 'application/octet-stream',
      sizeBytes: size,
      modifiedTime:
          _parseTime(entry['lastUpdateDate'] ?? entry['createDate']) ??
          DateTime.now(),
      captureTime: _parseTime(entry['createDate'] ?? entry['lastUpdateDate']),
      remoteVersion: entry['rev']?.toString(),
      width: (entry['width'] as num?)?.toInt(),
      height: (entry['height'] as num?)?.toInt(),
      durationMs: (entry['duration'] as num?)?.toInt(),
      thumbnailUrl: entry['icon']?['smallUrl'] as String?,
    );
  }

  // ---- helpers -----------------------------------------------------------

  static List<Map<String, dynamic>> _fileList(Map<String, dynamic>? body) {
    final list = body?['fileList'];
    if (list is List) {
      return list.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  static DateTime? _parseTime(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value) ??
          (int.tryParse(value) != null
              ? DateTime.fromMillisecondsSinceEpoch(int.parse(value))
              : null);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }
}

/// 创建天翼云盘 Provider。
ProviderTianyi createProviderTianyi({
  Dio? dio,
  OAuthAppConfig? oauth,
  OAuthAuthorizer? authorizer,
}) => ProviderTianyi(
  dio: dio ?? Dio(),
  oauth: oauth ?? OAuthAppConfig.fromEnvironment('SGPW_TIANYI'),
  authorizer: authorizer ?? _unavailableAuthorizer,
);

final OAuthAuthorizer _unavailableAuthorizer = _NoopAuthorizer();

class _NoopAuthorizer implements OAuthAuthorizer {
  @override
  Future<Uri?> authorize(Uri authorizeUrl) async => null;
}
