import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../data/db/app_database.dart';
import '../../data/provider/provider_models.dart';

/// 统一媒体卡片（PRD §5.1）：
/// - 固定纵横比 1.45 : 1
/// - CenterCrop 缩略策略
/// - 类型标识 + 视频时长
class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.item,
    required this.previewDir,
    this.isTv = false,
    this.autofocus = false,
    this.onTap,
  });

  final MediaItem item;
  final Directory previewDir;
  final bool isTv;
  final bool autofocus;
  final VoidCallback? onTap;

  static const double aspectRatio = 1.45;

  bool get _isVideo => item.mediaType == MediaType.video.wireName;

  File? get _previewFile {
    final path = item.previewPath;
    if (path == null || path.isEmpty) return null;
    final f = File('${previewDir.path}/$path');
    return f.existsSync() ? f : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(isTv ? 16 : 12);

    final card = AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(theme),
            if (_isVideo)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: isTv ? 22 : 16,
                        color: Colors.white,
                      ),
                      if (item.durationMs != null && item.durationMs! > 0)
                        Text(
                          formatDuration(item.durationMs!),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTv ? 16 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (isTv) {
      return FocusableActionDetector(
        autofocus: autofocus,
        mouseCursor: SystemMouseCursors.click,
        child: Builder(
          builder: (context) {
            final focused = Focus.of(context).hasFocus;
            return Transform.scale(
              scale: focused ? 1.06 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: focused
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 4,
                  ),
                ),
                child: card,
              ),
            );
          },
        ),
      );
    }

    return InkWell(onTap: onTap, borderRadius: radius, child: card);
  }

  Widget _buildImage(ThemeData theme) {
    final file = _previewFile;
    if (file != null) {
      return Image.file(
        file,
        fit: BoxFit.cover, // CenterCrop
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _placeholder(theme),
      );
    }
    return _placeholder(theme);
  }

  Widget _placeholder(ThemeData theme) => Container(
    color: theme.colorScheme.surfaceContainerHighest,
    child: Icon(
      _isVideo ? Icons.videocam_outlined : Icons.photo_outlined,
      size: isTv ? 56 : 32,
      color: theme.colorScheme.outline,
    ),
  );
}
