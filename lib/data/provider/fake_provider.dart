import 'dart:typed_data';

import '../../core/error/network_error.dart';
import '../../core/result/result.dart';
import 'cloud_provider.dart';
import 'provider_models.dart';

/// 内存 Fake Provider：测试与开发演示用。
///
/// 提供可配置目录树、分页、错误注入。
class FakeCloudProvider extends CloudProvider {
  FakeCloudProvider({
    this.folderTree = const {},
    List<RemoteMedia> files = const [],
    this.pageSize = 100,
    this.throwNetworkError = false,
    this.credentialsExpired = false,
  }) : _files = List.of(files);

  /// folderId → 子文件夹列表；null key 为根。
  final Map<String?, List<RemoteFolder>> folderTree;
  final List<RemoteMedia> _files;
  final int pageSize;

  /// 错误注入开关（同步失败保留旧数据测试）。
  bool throwNetworkError;
  bool credentialsExpired;

  static final _fakeCredentials = Credentials(
    accessToken: 'fake-access-token',
    refreshToken: 'fake-refresh-token',
    expiresAt: DateTime.fromMillisecondsSinceEpoch(4102444800000), // 2100-01-01
    tokenType: 'Bearer',
    accountId: 'fake-account',
  );

  @override
  ProviderType get type => ProviderType.cloud115;

  @override
  bool get isConfigured => true;

  void seedFiles(List<RemoteMedia> files) {
    _files
      ..clear()
      ..addAll(files);
  }

  @override
  Future<AuthResult> authorize() async => AuthSuccess(_fakeCredentials);

  @override
  Future<AuthResult> refreshCredential() async => AuthSuccess(_fakeCredentials);

  @override
  Future<CredentialState> validateCredential() async => credentialsExpired
      ? CredentialState.needReauth
      : CredentialState.authenticated;

  @override
  Future<Result<List<RemoteFolder>>> listFolders(String? parentFolderId) async {
    if (throwNetworkError) return const Err(Offline());
    return Ok(List.unmodifiable(folderTree[parentFolderId] ?? const []));
  }

  @override
  Future<Result<RemotePage<RemoteMedia>>> listMedia(
    String folderId,
    String? cursor,
  ) async {
    if (throwNetworkError) return const Err(Offline());
    final pageFiles = _files.where((f) => f.parentFolderId == folderId).toList()
      ..sort((a, b) => a.remoteFileId.compareTo(b.remoteFileId));
    final start = int.tryParse(cursor ?? '0') ?? 0;
    final end = (start + pageSize).clamp(0, pageFiles.length);
    final slice = pageFiles.sublist(start, end);
    return Ok(
      RemotePage(
        items: slice,
        nextCursor: end < pageFiles.length ? end.toString() : null,
      ),
    );
  }

  @override
  Future<Result<PlayableSource>> getPlayableUrl(String mediaId) async {
    if (throwNetworkError) return const Err(Offline());
    return Ok(
      PlayableSource(
        url: 'https://fake.local/media/$mediaId.mp4',
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      ),
    );
  }

  @override
  Future<Result<ImageSource>> getOriginalImageSource(String mediaId) async {
    if (throwNetworkError) return const Err(Offline());
    return Ok(ImageSource(url: 'https://fake.local/image/$mediaId.jpg'));
  }

  @override
  Future<Result<Uint8List>> downloadBytes(String url) async {
    if (throwNetworkError) return const Err(Offline());
    // 1x1 像素 PNG。
    return Ok(
      Uint8List.fromList(const [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x62,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ]),
    );
  }

  @override
  Future<Result<void>> logoutOrRevoke() async => const Ok(null);
}
