import 'package:dio/dio.dart';

import 'cloud_provider.dart';
import 'fake_provider.dart';
import 'oauth/oauth_core.dart';
import 'provider_115.dart';
import 'provider_models.dart';
import 'provider_tianyi.dart';

/// Provider 注册表：按类型创建/复用 Provider 实例。
///
/// 若使用 Fake 模式（--dart-define SGPW_USE_FAKE_PROVIDER=true），
/// 两个云盘位都使用 FakeCloudProvider（演示与开发用）。
class ProviderRegistry {
  ProviderRegistry({
    Dio? dio,
    OAuthAuthorizer? authorizer,
    bool useFake = false,
  }) : _dio = dio ?? Dio(),
       _useFake = useFake || _fakeModeEnabled {
    _authorizer = authorizer;
  }

  final Dio _dio;
  OAuthAuthorizer? _authorizer;
  final bool _useFake;
  final Map<ProviderType, CloudProvider> _instances = {};

  static const _fakeModeEnabled = bool.fromEnvironment(
    'SGPW_USE_FAKE_PROVIDER',
    defaultValue: false,
  );

  CloudProvider providerOf(ProviderType type) => _instances.putIfAbsent(
    type,
    () => switch (type) {
      ProviderType.cloud115 =>
        _useFake
            ? FakeCloudProvider()
            : createProvider115(dio: _dio, authorizer: _authorizer),
      ProviderType.tianyiCloud =>
        _useFake
            ? FakeCloudProvider()
            : createProviderTianyi(dio: _dio, authorizer: _authorizer),
    },
  );

  List<CloudProvider> get all => ProviderType.values.map(providerOf).toList();
}
