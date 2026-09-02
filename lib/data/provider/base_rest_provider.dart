import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/error/network_error.dart';
import '../../core/result/result.dart';
import 'oauth/oauth_core.dart';
import 'cloud_provider.dart';
import 'provider_models.dart';

/// REST 型云盘 Provider 公共基类：
/// - OAuth token 交换 / 刷新
/// - 401 自动 refresh 一次并重试
/// - HTTP 状态码 → 统一 NetworkError 映射
abstract class BaseRestCloudProvider extends CloudProvider {
  BaseRestCloudProvider({
    required this.dio,
    required this.oauth,
    required this.authorizer,
  });

  final Dio dio;
  final OAuthAppConfig oauth;
  final OAuthAuthorizer authorizer;

  Credentials? _credentials;
  String? _pkceVerifier;

  /// 凭据刷新回调（由 Repository 持久化）。
  void Function(Credentials credentials)? onCredentialRefreshed;

  @override
  bool get isConfigured => oauth.isConfigured;

  /// 注入当前凭据（Repository 从 DB 解密后设置）。
  void applyCredentials(Credentials? credentials) => _credentials = credentials;

  Credentials? get currentCredentials => _credentials;

  // ---- 端点定义（子类提供，以官方开放平台文档为准） --------------------------

  Uri buildAuthorizeUrl(String state, String codeChallenge);
  String get tokenEndpoint;
  String get apiBase;
  Future<String?> fetchAccountId(Credentials credentials);

  /// 解析云盘文件列表条目 → RemoteMedia（子类实现）。
  RemoteMedia? parseFileEntry(
    Map<String, dynamic> entry,
    String parentFolderId,
  );
  RemoteFolder? parseFolderEntry(Map<String, dynamic> entry);

  // ---- OAuth ------------------------------------------------------------

  @override
  Future<AuthResult> authorize() async {
    if (!isConfigured) {
      return AuthUnavailable('${type.displayName}官方开放平台凭证未配置，Provider 不可用');
    }
    final state = _randomState();
    _pkceVerifier = Pkce.generateVerifier();
    final url = buildAuthorizeUrl(state, Pkce.challengeFrom(_pkceVerifier!));
    final callback = await authorizer.authorize(url);
    if (callback == null) {
      return const AuthFailed('授权已取消');
    }
    if (OAuthCallback.stateOf(callback) != state) {
      return const AuthFailed('授权 state 校验失败');
    }
    final code = OAuthCallback.codeOf(callback);
    if (code == null || code.isEmpty) {
      return const AuthFailed('授权回调缺少 code');
    }
    try {
      final creds = await _exchangeToken(
        grantType: 'authorization_code',
        code: code,
      );
      final accountId = await fetchAccountId(creds) ?? 'default';
      final complete = creds.copyWith(accountId: accountId);
      _credentials = complete;
      return AuthSuccess(complete);
    } catch (e) {
      return AuthFailed(e);
    }
  }

  @override
  Future<AuthResult> refreshCredential() async {
    final creds = _credentials;
    if (creds == null || !isConfigured) {
      return const AuthNeedReauth();
    }
    try {
      final refreshed = await _exchangeToken(
        grantType: 'refresh_token',
        refreshToken: creds.refreshToken,
      );
      final complete = refreshed.copyWith(accountId: creds.accountId);
      _credentials = complete;
      onCredentialRefreshed?.call(complete);
      return AuthSuccess(complete);
    } catch (_) {
      return const AuthNeedReauth();
    }
  }

  Future<Credentials> _exchangeToken({
    required String grantType,
    String? code,
    String? refreshToken,
  }) async {
    final data = <String, dynamic>{
      'client_id': oauth.clientId,
      'client_secret': oauth.clientSecret,
      'grant_type': grantType,
    };
    if (code != null) data['code'] = code;
    if (refreshToken != null) data['refresh_token'] = refreshToken;
    if (code != null && _pkceVerifier != null) {
      data['code_verifier'] = _pkceVerifier;
    }
    final response = await dio.post<Map<String, dynamic>>(
      tokenEndpoint,
      data: data,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final body = response.data ?? const {};
    final accessToken = body['access_token'] as String?;
    final token = body['refresh_token'] as String? ?? refreshToken ?? '';
    final expiresIn = (body['expires_in'] as num?)?.toInt() ?? 3600;
    if (accessToken == null || accessToken.isEmpty) {
      throw const Unauthorized();
    }
    return Credentials(
      accessToken: accessToken,
      refreshToken: token,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      tokenType: body['token_type'] as String? ?? 'Bearer',
    );
  }

  @override
  Future<CredentialState> validateCredential() async {
    final creds = _credentials;
    if (creds == null) return CredentialState.needReauth;
    if (!isConfigured) return CredentialState.unavailable;
    if (!creds.isExpired) return CredentialState.authenticated;
    final refreshed = await refreshCredential();
    return refreshed is AuthSuccess
        ? CredentialState.authenticated
        : CredentialState.needReauth;
  }

  // ---- HTTP guard ----------------------------------------------------------

  /// 带统一错误映射 + 401 自动刷新重试一次的请求封装。
  Future<Result<T>> guarded<T>(Future<T> Function() body) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return Ok(await body());
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 401 && attempt == 0) {
          final refreshed = await refreshCredential();
          if (refreshed is! AuthSuccess) {
            return Err(const Unauthorized());
          }
          continue;
        }
        if (status != null) return Err(mapHttpStatus(status));
        return Err(mapDioError(e));
      } on SocketException {
        return const Err(Offline());
      } on NetworkError catch (e) {
        return Err(e);
      } catch (e) {
        return Err(UnknownError(e));
      }
    }
    return Err(const Unauthorized());
  }

  Map<String, String> get _authHeaders {
    final creds = _credentials;
    if (creds == null) throw const Unauthorized();
    return {'Authorization': '${creds.tokenType} ${creds.accessToken}'};
  }

  Future<Response<T>> authGet<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) => dio.get<T>(
    path,
    queryParameters: query,
    options: (options ?? Options()).copyWith(
      headers: {...?options?.headers, ..._authHeaders},
    ),
  );

  Future<Response<T>> authPost<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) => dio.post<T>(
    path,
    data: data,
    queryParameters: query,
    options: Options(
      headers: _authHeaders,
      contentType: Headers.jsonContentType,
    ),
  );

  @override
  Future<Result<Uint8List>> downloadBytes(String url) async {
    try {
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return Ok(Uint8List.fromList(response.data ?? const []));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null) return Err(mapHttpStatus(status));
      return Err(mapDioError(e));
    } catch (e) {
      return Err(UnknownError(e));
    }
  }

  @override
  Future<Result<void>> logoutOrRevoke() async {
    _credentials = null;
    _pkceVerifier = null;
    return const Ok(null);
  }

  String _randomState() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      identityHashCode(this).toRadixString(36);
}
