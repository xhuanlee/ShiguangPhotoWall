import 'package:dio/dio.dart';

import '../../core/error/network_error.dart';
import '../../core/result/result.dart';
import 'oauth/oauth_core.dart';
import 'base_rest_provider.dart';
import 'provider_models.dart';

/// 115 网盘 Provider（官方 115 生活开放平台）。
///
/// 端点以官方开放平台当前文档为准（PRD §58）；如与实际授权有差异，
/// 只修改本文件，不改业务层。
class Provider115 extends BaseRestCloudProvider {
  Provider115({
    required super.dio,
    required super.oauth,
    required super.authorizer,
  });

  static const String defaultAuthorizeUrl = String.fromEnvironment(
    'SGPW_115_AUTHORIZE_URL',
    defaultValue: 'https://passportapi.115.com/open/authorize',
  );
  static const String defaultTokenUrl = String.fromEnvironment(
    'SGPW_115_TOKEN_URL',
    defaultValue: 'https://passportapi.115.com/open/oauth/token',
  );
  static const String defaultApiBase = String.fromEnvironment(
    'SGPW_115_API_BASE',
    defaultValue: 'https://proapi.115.com/open',
  );

  @override
  ProviderType get type => ProviderType.cloud115;

  @override
  Uri buildAuthorizeUrl(String state, String codeChallenge) =>
      Uri.parse(defaultAuthorizeUrl).replace(
        queryParameters: {
          'app_id': oauth.clientId,
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
        '$apiBase/user/info',
      );
      final data = response.data;
      final user = data?['data'] as Map<String, dynamic>?;
      return user?['user_id']?.toString() ?? user?['account']?.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<List<RemoteFolder>>> listFolders(String? parentFolderId) =>
      guarded(() async {
        final folders = <RemoteFolder>[];
        String? offset;
        const limit = 100;
        var currentOffset = 0;
        // 115 列表接口返回文件+目录混合，目录条目聚合后返回。
        do {
          final response = await authPost<Map<String, dynamic>>(
            '$apiBase/ufile/list',
            data: {
              'cid': parentFolderId ?? '0',
              'limit': limit,
              'offset': currentOffset,
              'type': 0,
            },
          );
          final list = _entryList(response.data);
          for (final entry in list) {
            final folder = parseFolderEntry(entry);
            if (folder != null) folders.add(folder);
          }
          offset = _nextOffset(response.data);
          currentOffset += limit;
        } while (offset != null);
        return folders;
      });

  @override
  Future<Result<RemotePage<RemoteMedia>>> listMedia(
    String folderId,
    String? cursor,
  ) => guarded(() async {
    final response = await authPost<Map<String, dynamic>>(
      '$apiBase/ufile/list',
      data: {
        'cid': folderId,
        'limit': 100,
        'offset': int.tryParse(cursor ?? '0') ?? 0,
        'type': 0,
      },
    );
    final list = _entryList(response.data);
    final media = <RemoteMedia>[];
    for (final entry in list) {
      final item = parseFileEntry(entry, folderId);
      if (item != null) media.add(item);
    }
    final next = _nextOffset(response.data);
    return RemotePage(
      items: media,
      nextCursor: next == null ? null : (int.tryParse(next) ?? 0).toString(),
    );
  });

  @override
  Future<Result<PlayableSource>> getPlayableUrl(String mediaId) async {
    final result = await guarded(() async {
      final response = await authPost<Map<String, dynamic>>(
        '$apiBase/ufile/downurl',
        data: {'fid': mediaId},
      );
      final url = _extractUrl(response.data?['data']);
      if (url == null) throw const NotFound();
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
      final response = await authPost<Map<String, dynamic>>(
        '$apiBase/ufile/downurl',
        data: {'fid': mediaId},
      );
      final url = _extractUrl(response.data?['data']);
      if (url == null) throw const NotFound();
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
    // 115 目录条目带 "fc"（子项数）或 pid 结构。
    final isFolder = entry['fc'] != null || (entry['pid'] as String?) != null;
    if (!isFolder) return null;
    final id = entry['cid']?.toString() ?? entry['fid']?.toString();
    final name = entry['n'] as String?;
    if (id == null || name == null) return null;
    return RemoteFolder(id: id, name: name, parentId: entry['pid']?.toString());
  }

  @override
  RemoteMedia? parseFileEntry(
    Map<String, dynamic> entry,
    String parentFolderId,
  ) {
    // 文件条目有 "fid" 且无 "fc"。
    final fid = entry['fid']?.toString();
    if (fid == null || entry['fc'] != null) return null;
    final name = entry['n'] as String?;
    if (name == null) return null;
    final mediaType = MediaType.fromFile(name, null);
    if (mediaType == null) return null;
    return RemoteMedia(
      remoteFileId: fid,
      parentFolderId: parentFolderId,
      name: name,
      mediaType: mediaType,
      mimeType: entry['ico'] as String? ?? 'application/octet-stream',
      sizeBytes: (entry['s'] as num?)?.toInt() ?? 0,
      modifiedTime: _parseTime(entry['t'] ?? entry['upt']) ?? DateTime.now(),
      remoteVersion: entry['sha1'] as String?,
      checksum: entry['sha1'] as String?,
    );
  }

  // ---- helpers -----------------------------------------------------------

  static List<Map<String, dynamic>> _entryList(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is Map<String, dynamic>) {
      final list = data['list'];
      if (list is List) {
        return list.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }

  static String? _nextOffset(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is Map<String, dynamic>) {
      final count = (data['count'] as num?)?.toInt() ?? 0;
      final offset = (data['offset'] as num?)?.toInt() ?? 0;
      final records =
          (data['records'] as num?)?.toInt() ??
          ((data['list'] as List?)?.length ?? 0);
      if (offset + records < count) return (offset + records).toString();
    }
    return null;
  }

  static String? _extractUrl(Object? data) {
    if (data is Map<String, dynamic>) {
      final url = data['url'] ?? data['file_url'];
      if (url is String && url.isNotEmpty) return url;
      // {fid: {url: ...}} 结构
      for (final value in data.values) {
        if (value is Map<String, dynamic>) {
          final u = value['url'] ?? value['file_url'];
          if (u is String && u.isNotEmpty) return u;
        }
      }
    }
    return null;
  }

  static DateTime? _parseTime(Object? value) {
    if (value is String) {
      final seconds = int.tryParse(value);
      if (seconds != null && seconds > 0) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
      return DateTime.tryParse(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
    }
    return null;
  }
}

/// 创建 115 Provider。
Provider115 createProvider115({
  Dio? dio,
  OAuthAppConfig? oauth,
  OAuthAuthorizer? authorizer,
}) => Provider115(
  dio: dio ?? Dio(),
  oauth: oauth ?? OAuthAppConfig.fromEnvironment('SGPW_115'),
  authorizer: authorizer ?? _unavailableAuthorizer,
);

final OAuthAuthorizer _unavailableAuthorizer = _NoopAuthorizer();

class _NoopAuthorizer implements OAuthAuthorizer {
  @override
  Future<Uri?> authorize(Uri authorizeUrl) async => null;
}
