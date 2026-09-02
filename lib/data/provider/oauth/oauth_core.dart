import 'dart:convert';

import 'package:crypto/crypto.dart';

/// OAuth 应用凭证（由构建时 --dart-define 或运行时配置注入）。
///
/// 未配置 → Provider 进入 UNAVAILABLE（PRD 实现前置约束）。
class OAuthAppConfig {
  const OAuthAppConfig({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
  });

  final String clientId;
  final String clientSecret;
  final String redirectUri;

  bool get isConfigured =>
      clientId.isNotEmpty && clientSecret.isNotEmpty && redirectUri.isNotEmpty;

  static const empty = OAuthAppConfig(
    clientId: '',
    clientSecret: '',
    redirectUri: '',
  );

  /// 从环境变量读取（--dart-define）。
  static OAuthAppConfig fromEnvironment(String prefix) => OAuthAppConfig(
    clientId: _env('${prefix}_APP_ID'),
    clientSecret: _env('${prefix}_APP_SECRET'),
    redirectUri: _env(
      '${prefix}_REDIRECT_URI',
      fallback: 'sgphotowall://oauth/callback',
    ),
  );
}

String _env(String name, {String fallback = ''}) {
  final v = String.fromEnvironment(name);
  return v.isEmpty ? fallback : v;
}

/// PKCE 工具。
class Pkce {
  Pkce._();

  static String generateVerifier() {
    final rng =
        DateTime.now().microsecondsSinceEpoch.toString() +
        identityHashCode(Object()).toString();
    return base64Url
        .encode(
          utf8.encode('sgpw-$rng-${DateTime.now().millisecondsSinceEpoch}'),
        )
        .replaceAll('=', '');
  }

  static String challengeFrom(String verifier) => base64Url
      .encode(sha256.convert(utf8.encode(verifier)).bytes)
      .replaceAll('=', '');
}

/// OAuth 授权结果回调。
abstract class OAuthAuthorizer {
  /// 打开授权页并等待回调 URI（含 code）。
  Future<Uri?> authorize(Uri authorizeUrl);
}

/// 浏览器授权实现（url_launcher 由外部注入，便于测试）。
class BrowserOAuthAuthorizer implements OAuthAuthorizer {
  BrowserOAuthAuthorizer(this._launch, this._waitForCallback);

  final Future<bool> Function(Uri url) _launch;
  final Future<Uri?> Function(Uri url, Duration timeout) _waitForCallback;

  @override
  Future<Uri?> authorize(Uri authorizeUrl) async {
    final ok = await _launch(authorizeUrl);
    if (!ok) return null;
    return _waitForCallback(authorizeUrl, const Duration(minutes: 5));
  }
}

/// 从回调 URI 中提取 code / state。
class OAuthCallback {
  const OAuthCallback._();
  static String? codeOf(Uri uri) => uri.queryParameters['code'];
  static String? stateOf(Uri uri) => uri.queryParameters['state'];
}
