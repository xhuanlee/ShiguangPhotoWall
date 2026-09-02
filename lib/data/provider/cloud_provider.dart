import 'dart:typed_data';

import '../../core/result/result.dart';
import 'provider_models.dart';

/// 云盘 Provider 统一接口（PRD §4.1）。
///
/// Provider 不得直接操作 DAO，不得直接修改 UI State。
abstract class CloudProvider {
  ProviderType get type;

  /// 是否已配置官方开放平台凭证；未配置则进入 UNAVAILABLE 状态。
  bool get isConfigured;

  /// 发起授权（OAuth / 官方开放平台流程）。
  Future<AuthResult> authorize();

  /// 刷新凭据。
  Future<AuthResult> refreshCredential();

  /// 校验当前凭据。
  Future<CredentialState> validateCredential();

  Future<Result<List<RemoteFolder>>> listFolders(String? parentFolderId);

  Future<Result<RemotePage<RemoteMedia>>> listMedia(
    String folderId,
    String? cursor,
  );

  Future<Result<PlayableSource>> getPlayableUrl(String mediaId);

  Future<Result<ImageSource>> getOriginalImageSource(String mediaId);

  /// 下载字节（原图 / 缩略图）。
  Future<Result<Uint8List>> downloadBytes(String url);

  Future<Result<void>> logoutOrRevoke();
}
