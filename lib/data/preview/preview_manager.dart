import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../provider/cloud_provider.dart';
import '../provider/provider_models.dart';
import 'preview_store.dart';

/// Preview 生成（PRD §12 / §24.6）：
/// - 图片：下载原图 → 采样解码 → 长边 720（TV 可 1080）→ WebP
/// - 视频：优先云盘缩略图 URL；失败显示统一占位
/// - 生成并发受限
class PreviewManager {
  PreviewManager({
    required this.store,
    this.longEdge = PreviewStore.gridLongEdge,
    this.concurrency = 3,
  });

  final PreviewStore store;
  final int longEdge;
  final int concurrency;

  /// 生成单个媒体 preview；返回相对路径，失败返回 null（调用方显示占位）。
  Future<String?> generate({
    required CloudProvider provider,
    required String providerType,
    required String accountKey,
    required RemoteMedia media,
  }) async {
    final relative = PreviewStore.relativeName(
      providerType: providerType,
      accountKey: accountKey,
      remoteId: media.remoteFileId,
      version: media.remoteVersion,
      size: media.sizeBytes,
    );
    if (store.exists(relative)) return relative;

    final bytes = await _fetchBytes(provider, media);
    if (bytes == null) return null;

    final encoded = _encodePreview(bytes);
    if (encoded == null) return null;

    await store.write(relative, encoded);
    return relative;
  }

  Future<Uint8List?> _fetchBytes(
    CloudProvider provider,
    RemoteMedia media,
  ) async {
    switch (media.mediaType) {
      case MediaType.image:
        final source = await provider.getOriginalImageSource(
          media.remoteFileId,
        );
        if (source.isErr) return null;
        final bytes = await provider.downloadBytes(source.getOrThrow().url);
        return bytes.getOrNull();
      case MediaType.video:
        final thumb = media.thumbnailUrl;
        if (thumb == null) return null;
        final bytes = await provider.downloadBytes(thumb);
        return bytes.getOrNull();
    }
  }

  /// 解码 → 长边缩放 → WebP 编码。
  Uint8List? _encodePreview(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      final scaled = _resizeLongEdge(decoded, longEdge);
      return Uint8List.fromList(img.WebPEncoder().encode(scaled));
    } catch (_) {
      return null;
    }
  }

  static img.Image _resizeLongEdge(img.Image image, int targetLongEdge) {
    final w = image.width;
    final h = image.height;
    final longEdge = w >= h ? w : h;
    if (longEdge <= targetLongEdge) return image;
    final ratio = targetLongEdge / longEdge;
    return img.copyResize(
      image,
      width: (w * ratio).round(),
      height: (h * ratio).round(),
    );
  }
}
