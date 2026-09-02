import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/provider/provider_models.dart';
import '../gallery/media_grid.dart';
import 'auto_play_controller.dart';
import 'media_source_resolver.dart';

/// 手机 Viewer（PRD §8）：
/// - 上滑下一项 / 下滑上一项（垂直 PageView）
/// - 照片按原始比例完整显示（contain，不裁切）
/// - 视频按原始宽高比播放，结束自动下一项（自动播放开启时）
/// - 点击空白区显示/隐藏控制栏；返回关闭
class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({super.key, required this.args});

  final ViewerArgs args;

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  late final AutoPlayController _autoPlay;
  Timer? _photoTimer;

  VideoPlayerController? _videoController;
  bool _videoInitializing = false;
  String? _videoError;
  bool _controlsVisible = true;
  int _index = 0;

  List<MediaItem> get _items => widget.args.items;
  MediaItem get _current => _items[_index];
  bool get _isVideo => _current.mediaType == MediaType.video.wireName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _index = widget.args.initialIndex.clamp(0, _items.length - 1);
    _pageController = PageController(initialPage: _index);
    final settings = ref.read(playbackSettingsProvider).settings;
    _autoPlay = AutoPlayController(
      autoPlay: settings.autoPlay,
      photoDuration: Duration(seconds: settings.photoDurationSec),
    );
    _applyDecision(_autoPlay.onMediaOpened(isVideo: _isVideo));
    if (_isVideo) _initVideo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _photoTimer?.cancel();
    _videoController?.dispose();
    _pageController.dispose();
    _autoPlay.onClose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applyDecision(_autoPlay.onForeground(isVideo: _isVideo));
      _videoController?.play();
    } else {
      _applyDecision(_autoPlay.onBackground());
      _videoController?.pause();
    }
  }

  void _applyDecision(AutoPlayDecision decision) {
    switch (decision) {
      case AutoPlayDecision.schedulePhotoTimer:
        _photoTimer?.cancel();
        _photoTimer = Timer(_autoPlay.photoDuration, () {
          _applyDecision(_autoPlay.onPhotoTimerFired());
        });
      case AutoPlayDecision.cancelTimer:
        _photoTimer?.cancel();
        _photoTimer = null;
      case AutoPlayDecision.advanceNext:
        _next();
      case AutoPlayDecision.none:
        break;
    }
  }

  void _next() => _goTo(_index + 1);

  void _goTo(int target) {
    if (target < 0 || target >= _items.length) return;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _initVideo() async {
    setState(() {
      _videoInitializing = true;
      _videoError = null;
    });
    await _videoController?.dispose();
    _videoController = null;

    final url = await ref
        .read(mediaSourceResolverProvider)
        .playableUrlOf(_current);
    if (!mounted) return;
    if (url == null) {
      setState(() {
        _videoInitializing = false;
        _videoError = '无法播放此视频';
      });
      return;
    }
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _videoInitializing = false);
      _videoController = controller;
      controller.addListener(_onVideoEvent);
      await controller.play();
    } catch (_) {
      if (mounted) {
        setState(() {
          _videoInitializing = false;
          _videoError = '无法播放此视频';
        });
      }
      await controller.dispose();
    }
  }

  void _onVideoEvent() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.position >= controller.value.duration) {
      _applyDecision(_autoPlay.onVideoEnded());
    }
  }

  void _onPageChanged(int page) {
    final manual = page != _index;
    setState(() => _index = page);
    _applyDecision(_autoPlay.onManualSwitch(isVideo: _isVideo));
    if (_isVideo) {
      _initVideo();
    } else {
      _videoController?.dispose();
      _videoController = null;
      setState(() => _videoError = null);
    }
    // 手动切换重置计时（manual 参数用于语义标记）。
    debugPrint('viewer page -> $page (manual: $manual)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _controlsVisible = !_controlsVisible),
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _items.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            final item = _items[index];
            final isVideo = item.mediaType == MediaType.video.wireName;
            if (isVideo) {
              return _VideoPane(
                controller: index == _index ? _videoController : null,
                initializing: index == _index && _videoInitializing,
                error: index == _index ? _videoError : null,
                onRetry: _initVideo,
                controlsVisible: index == _index && _controlsVisible,
                onTogglePlay: _togglePlay,
              );
            }
            return _PhotoPane(
              item: item,
              previewDir:
                  ref.watch(previewDirProvider).value ?? Directory.systemTemp,
            );
          },
        ),
      ),
    );
  }

  void _togglePlay() {
    final controller = _videoController;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
      _applyDecision(_autoPlay.onPause());
    } else {
      controller.play();
      _applyDecision(_autoPlay.onResume(isVideo: true));
    }
    setState(() {});
  }
}

/// 照片面板：原始比例 contain，双指缩放。
class _PhotoPane extends StatelessWidget {
  const _PhotoPane({required this.item, required this.previewDir});

  final MediaItem item;
  final Directory previewDir;

  File? get _previewFile {
    final path = item.previewPath;
    if (path == null || path.isEmpty) return null;
    final f = File('${previewDir.path}/$path');
    return f.existsSync() ? f : null;
  }

  @override
  Widget build(BuildContext context) {
    final file = _previewFile;
    if (file == null) {
      return const Center(
        child: Icon(Icons.photo_outlined, size: 64, color: Colors.white38),
      );
    }
    return InteractiveViewer(
      maxScale: 5,
      child: Center(
        child: Image.file(
          file,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const Icon(
            Icons.broken_image_outlined,
            size: 64,
            color: Colors.white38,
          ),
        ),
      ),
    );
  }
}

/// 视频面板：原始宽高比，不拉伸。
class _VideoPane extends StatelessWidget {
  const _VideoPane({
    required this.controller,
    required this.initializing,
    required this.error,
    required this.onRetry,
    required this.controlsVisible,
    required this.onTogglePlay,
  });

  final VideoPlayerController? controller;
  final bool initializing;
  final String? error;
  final VoidCallback onRetry;
  final bool controlsVisible;
  final VoidCallback onTogglePlay;

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      );
    }
    final c = controller;
    if (c == null || !c.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(child: VideoPlayer(c)),
        if (controlsVisible)
          Positioned.fill(
            child: Center(
              child: IconButton(
                iconSize: 56,
                icon: Icon(
                  c.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: Colors.white70,
                ),
                onPressed: onTogglePlay,
              ),
            ),
          ),
        if (controlsVisible)
          Positioned(
            bottom: 32,
            left: 32,
            right: 32,
            child: VideoProgressIndicator(
              c,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                backgroundColor: Colors.white24,
              ),
            ),
          ),
      ],
    );
  }
}
