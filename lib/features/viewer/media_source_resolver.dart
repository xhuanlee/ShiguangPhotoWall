import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/provider/provider_models.dart';

/// 媒体源解析（PRD §18）：
/// 播放 URL 具有时效性，每次播放前重新获取，禁止长期持久化。
class MediaSourceResolver {
  const MediaSourceResolver(this.ref);

  final Ref ref;

  /// 获取视频可播放 URL（失败返回 null）。
  Future<String?> playableUrlOf(MediaItem item) async {
    final provider = _providerOf(item);
    if (provider == null) return null;
    final result = await provider.getPlayableUrl(item.remoteFileId);
    return result.getOrNull()?.url;
  }

  /// 获取图片原始字节（Viewer 高清展示用；preview 优先由 UI 处理）。
  Future<Uint8List?> originalBytesOf(MediaItem item) async {
    final provider = _providerOf(item);
    if (provider == null) return null;
    final source = await provider.getOriginalImageSource(item.remoteFileId);
    if (source.isErr) return null;
    final bytes = await provider.downloadBytes(source.getOrThrow().url);
    return bytes.getOrNull();
  }

  dynamic _providerOf(MediaItem item) {
    final type = ProviderType.fromWire(item.providerType);
    if (type == null) return null;
    final registry = ref.read(providerRegistryProvider);
    // 115/天翼共用 REST Provider；凭据在同步时已注入。
    return registry.providerOf(type);
  }
}

final mediaSourceResolverProvider = Provider<MediaSourceResolver>(
  (ref) => MediaSourceResolver(ref),
);
