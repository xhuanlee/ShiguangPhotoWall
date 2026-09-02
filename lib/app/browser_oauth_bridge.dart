import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/provider/oauth/oauth_core.dart';

/// 基于 url_launcher + app_links 的 OAuth 浏览器授权桥。
///
/// 流程：打开系统浏览器 → 等待深链回调 sgphotowall://oauth/callback?code=...
OAuthAuthorizer createBrowserOAuthAuthorizer() => BrowserOAuthAuthorizer(
  (url) => launchUrl(url, mode: LaunchMode.externalApplication),
  _waitForCallback,
);

Future<Uri?> _waitForCallback(Uri launchUrl, Duration timeout) async {
  final appLinks = AppLinks();
  // 先订阅再等待，避免竞态丢失回调。
  final completer = Completer<Uri?>();
  late final StreamSubscription sub;
  sub = appLinks.uriLinkStream.listen(
    (uri) {
      if (uri.scheme == 'sgphotowall' && !completer.isCompleted) {
        completer.complete(uri);
      }
    },
    onError: (_) {
      if (!completer.isCompleted) completer.complete(null);
    },
  );
  try {
    return await completer.future.timeout(timeout, onTimeout: () => null);
  } finally {
    await sub.cancel();
  }
}
