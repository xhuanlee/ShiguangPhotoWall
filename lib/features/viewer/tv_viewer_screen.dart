import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/provider/provider_models.dart';
import '../gallery/media_grid.dart';
import 'auto_play_controller.dart';
import 'media_source_resolver.dart';
import 'tv_seek_logic.dart';

/// TV Viewer（PRD §8.3）：
/// - 上键/短按左键：上一项；下键/短按右键：下一项
/// - 长按左/右键：视频快退/快进（递增步长 10s→30s→60s + HUD）
/// - OK：播放/暂停；Back：返回列表；图片忽略长按 seek
class TvViewerScreen extends ConsumerStatefulWidget {
  const TvViewerScreen({super.key, required this.args});

  final ViewerArgs args;

  @override
  ConsumerState<TvViewerScreen> createState() => _TvViewerScreenState();
}

class _TvViewerScreenState extends ConsumerState<TvViewerScreen>
    with WidgetsBindingObserver {
  late final AutoPlayController _autoPlay;
  final TvSeekLogic _seekLogic = TvSeekLogic();

  VideoPlayerController? _videoController;
  bool _videoInitializing = false;
  String? _videoError;
  Timer? _photoTimer;
  Timer? _hudTimer;

  /// HUD 展示的累计 seek 偏移（秒）。
  int _hudSeekSeconds = 0;
  bool _hudVisible = false;
  bool _paused = false;

  int _index = 0;

  List<MediaItem> get _items => widget.args.items;
  MediaItem get _current => _items[_index];
  bool get _isVideo => _current.mediaType == MediaType.video.wireName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _index = widget.args.initialIndex.clamp(0, _items.length - 1);
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
    _hudTimer?.cancel();
    _videoController?.dispose();
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

  // ---- 媒体切换 -----------------------------------------------------------

  void _next() => _switchTo(_index + 1);
  void _previous() => _switchTo(_index - 1);

  void _switchTo(int target) {
    if (target < 0 || target >= _items.length) return;
    setState(() => _index = target);
    _applyDecision(_autoPlay.onManualSwitch(isVideo: _isVideo));
    _hideHud();
    if (_isVideo) {
      _initVideo();
    } else {
      _disposeVideo();
    }
  }

  Future<void> _initVideo() async {
    setState(() {
      _videoInitializing = true;
      _videoError = null;
      _paused = false;
    });
    _disposeVideo();

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

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
  }

  void _onVideoEvent() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.position >= controller.value.duration) {
      _applyDecision(_autoPlay.onVideoEnded());
    }
  }

  void _togglePlayPause() {
    final controller = _videoController;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
      _applyDecision(_autoPlay.onPause());
      setState(() => _paused = true);
    } else {
      controller.play();
      _applyDecision(_autoPlay.onResume(isVideo: true));
      setState(() => _paused = false);
    }
  }

  // ---- Seek + HUD ----------------------------------------------------------

  void _seekBy(int seconds) {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration;
    var target = controller.value.position + Duration(seconds: seconds);
    // 到视频开头/结尾时停止继续 seek（PRD §8.3）。
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    controller.seekTo(target);
    // seek 期间视频暂停时仍可 seek（无需恢复播放状态）。
    _showHud(_hudSeekSeconds + seconds);
  }

  void _showHud(int cumulativeSeconds) {
    _hudTimer?.cancel();
    setState(() {
      _hudSeekSeconds = cumulativeSeconds;
      _hudVisible = true;
    });
    // HUD 500~800ms 内自动淡出。
    _hudTimer = Timer(const Duration(milliseconds: 700), _hideHud);
  }

  void _hideHud() {
    _hudTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _hudVisible = false;
      _hudSeekSeconds = 0;
    });
  }

  // ---- D-pad 事件 ----------------------------------------------------------

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    final isDown = event is KeyDownEvent;
    final isRepeat = event is KeyRepeatEvent;
    final isUp = event is KeyUpEvent;

    // 左右键：tap = 切换媒体 / 长按 = seek（仅视频）。
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      final forward = key == LogicalKeyboardKey.arrowRight;
      if (isDown) {
        _seekLogic.onDown(forward: forward, now: DateTime.now());
        return KeyEventResult.handled;
      }
      if (isRepeat) {
        final amount = _seekLogic.onRepeat(DateTime.now());
        if (amount != null && _isVideo) {
          _seekBy(amount.inSeconds);
        }
        return KeyEventResult.handled;
      }
      if (isUp) {
        final wasTap = _seekLogic.onUp();
        if (wasTap) {
          forward ? _next() : _previous();
        } else {
          _hideHud();
        }
        return KeyEventResult.handled;
      }
    }

    // 上下键：切换媒体。
    if (key == LogicalKeyboardKey.arrowUp && isDown) {
      _previous();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown && isDown) {
      _next();
      return KeyEventResult.handled;
    }

    // OK/Enter：播放/暂停视频。
    if ((key == LogicalKeyboardKey.select ||
            key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.space) &&
        isDown) {
      if (_isVideo) _togglePlayPause();
      return KeyEventResult.handled;
    }

    // Back：返回媒体列表。
    if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
      if (isDown) {
        Navigator.of(context).maybePop();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildMedia(),
            if (_hudVisible) _buildSeekHud(),
            Positioned(
              top: 24,
              left: 48,
              child: Text(
                '${_index + 1} / ${_items.length}',
                style: const TextStyle(color: Colors.white54, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (!_isVideo) {
      return _TvPhotoPane(
        item: _current,
        previewDir: ref.watch(previewDirProvider).value ?? Directory.systemTemp,
      );
    }
    if (_videoInitializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_videoError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _videoError!,
              style: const TextStyle(color: Colors.white70, fontSize: 24),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _initVideo,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('重试', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      );
    }
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(child: VideoPlayer(controller)),
        if (_paused)
          const Icon(
            Icons.pause_circle_outline,
            size: 96,
            color: Colors.white70,
          ),
        Positioned(
          bottom: 48,
          left: 96,
          right: 96,
          child: VideoProgressIndicator(
            controller,
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

  /// 长按 seek HUD：`-10s / -30s / -60s`、`+10s / +30s / +60s`。
  Widget _buildSeekHud() {
    final seconds = _hudSeekSeconds;
    final label = seconds >= 0 ? '+${seconds}s' : '$seconds s';
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              seconds >= 0 ? Icons.fast_forward : Icons.fast_rewind,
              color: Colors.white,
              size: 36,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// TV 照片面板：Fit Center，保持原始比例（PRD §8.1）。
class _TvPhotoPane extends StatelessWidget {
  const _TvPhotoPane({required this.item, required this.previewDir});

  final MediaItem item;
  final Directory previewDir;

  @override
  Widget build(BuildContext context) {
    final path = item.previewPath;
    if (path == null || path.isEmpty) {
      return const Center(
        child: Icon(Icons.photo_outlined, size: 96, color: Colors.white38),
      );
    }
    final file = File('${previewDir.path}/$path');
    if (!file.existsSync()) {
      return const Center(
        child: Icon(Icons.photo_outlined, size: 96, color: Colors.white38),
      );
    }
    return Center(
      child: Image.file(
        file,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const Icon(
          Icons.broken_image_outlined,
          size: 96,
          color: Colors.white38,
        ),
      ),
    );
  }
}
