import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/db/app_database.dart';

/// 分页媒体列表控制器（PRD §40：禁止一次性加载全部媒体）。
///
/// 基于 watchMediaPage(limit, offset=0)：已加载页数随滚动增长，
/// 数据库变更时自动重发当前窗口数据。
class MediaPagedListController extends ChangeNotifier {
  MediaPagedListController({
    required this.dao,
    this.mediaType,
    this.pageSize = 60,
  });

  final AppDao dao;

  /// null = 全部；'IMAGE' / 'VIDEO'。
  final String? mediaType;
  final int pageSize;

  List<MediaItem> items = const [];
  bool hasMore = true;
  bool loading = false;

  int _loadedPages = 1;
  StreamSubscription<List<MediaItem>>? _sub;

  void bind() {
    _sub?.cancel();
    _sub = dao
        .watchMediaPage(
          mediaType: mediaType,
          limit: pageSize * _loadedPages,
          offset: 0,
        )
        .listen((page) {
          items = page;
          hasMore = page.length >= pageSize * _loadedPages;
          loading = false;
          notifyListeners();
        });
  }

  /// 滚动接近底部时加载下一页。
  Future<void> loadMore() async {
    if (!hasMore || loading) return;
    loading = true;
    notifyListeners();
    // 先阻塞读取下一页判断是否还有更多，再扩窗订阅。
    final next = await dao.getMediaPage(
      mediaType: mediaType,
      limit: pageSize,
      offset: pageSize * _loadedPages,
    );
    if (next.isEmpty) {
      hasMore = false;
      loading = false;
      notifyListeners();
      return;
    }
    _loadedPages++;
    // watch 流会随窗口扩大自动重发。
    loading = false;
  }

  /// 同步完成后可能新增大量数据：重置回第一页窗口。
  void reset() {
    _loadedPages = 1;
    hasMore = true;
    bind();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
