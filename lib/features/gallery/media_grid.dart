import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import 'media_card.dart';
import 'media_list_controller.dart';

/// 媒体网格页面（首页/照片/视频共用，PRD §5-§7）。
///
/// - 照片与视频卡片大小完全相同
/// - 3~6 列自适应（TV 更大卡片与间距）
/// - 分页加载 + 滚动到底自动加载
class MediaGridScreen extends ConsumerStatefulWidget {
  const MediaGridScreen({
    super.key,
    this.mediaType,
    required this.title,
    this.isTv = false,
  });

  /// null = 全部 / 'IMAGE' / 'VIDEO'
  final String? mediaType;
  final String title;
  final bool isTv;

  @override
  ConsumerState<MediaGridScreen> createState() => _MediaGridScreenState();
}

class _MediaGridScreenState extends ConsumerState<MediaGridScreen> {
  late final MediaPagedListController controller;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    controller = MediaPagedListController(
      dao: ref.read(appDaoProvider),
      mediaType: widget.mediaType,
      pageSize: widget.isTv ? 90 : 60,
    )..bind();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 600) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewDir =
        ref.watch(previewDirProvider).value ?? Directory.systemTemp;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.items.isEmpty) {
          return _EmptyState(isTv: widget.isTv);
        }
        return GridView.builder(
          controller: _scroll,
          padding: widget.isTv
              ? const EdgeInsets.fromLTRB(48, 24, 48, 48)
              : const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.isTv ? 5 : _columnsOf(context),
            mainAxisSpacing: widget.isTv ? 20 : 8,
            crossAxisSpacing: widget.isTv ? 20 : 8,
            childAspectRatio: MediaCard.aspectRatio,
          ),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return MediaCard(
              item: item,
              previewDir: previewDir,
              isTv: widget.isTv,
              autofocus: widget.isTv && index == 0,
              onTap: () => _openViewer(context, index),
            );
          },
        );
      },
    );
  }

  int _columnsOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 6;
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    return 3;
  }

  void _openViewer(BuildContext context, int index) {
    Navigator.of(context).pushNamed(
      widget.isTv ? '/tv/viewer' : '/viewer',
      arguments: ViewerArgs(
        items: List.of(controller.items),
        initialIndex: index,
        mediaType: widget.mediaType,
      ),
    );
  }
}

/// Viewer 参数（当前已加载窗口 + 起始索引）。
class ViewerArgs {
  const ViewerArgs({
    required this.items,
    required this.initialIndex,
    this.mediaType,
  });

  final List<MediaItem> items;
  final int initialIndex;
  final String? mediaType;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isTv});

  final bool isTv;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: isTv ? 96 : 64,
            color: theme.colorScheme.outline,
          ),
          SizedBox(height: isTv ? 24 : 16),
          Text(
            '当前文件夹没有照片或视频',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: isTv ? 24 : 16,
              color: theme.colorScheme.outline,
            ),
          ),
          SizedBox(height: isTv ? 12 : 8),
          Text(
            '请先在设置中绑定云盘并选择同步文件夹',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: isTv ? 18 : 13,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
