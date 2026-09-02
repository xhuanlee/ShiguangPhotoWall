import 'package:flutter/foundation.dart';

/// 自动播放决策（PRD §9 / §28）。
enum AutoPlayDecision {
  /// 无操作。
  none,

  /// 照片：安排 photoDuration 计时。
  schedulePhotoTimer,

  /// 取消当前计时。
  cancelTimer,

  /// 立即切到下一项。
  advanceNext,
}

/// 自动播放状态机（纯逻辑，可测试）。
///
/// 规则：
/// - autoPlay OFF：任何事件不产生推进
/// - 照片：打开/手动切换 → 重置计时 → 到期 next
/// - 视频：仅在 ended 事件后 next；手动暂停不 next
/// - 后台：挂起计时；前台：照片恢复计时
/// - 手动上一张/下一张：立即重置当前媒体计时（视频重新开始播放由 UI 执行）
class AutoPlayController extends ChangeNotifier {
  AutoPlayController({required this.autoPlay, required this.photoDuration});

  final bool autoPlay;
  final Duration photoDuration;

  bool _paused = false;
  bool _background = false;
  bool _active = false;

  bool get isPaused => _paused;
  bool get isBackground => _background;
  bool get isActive => _active;

  bool get _canAdvance => autoPlay && !_paused && !_background;

  /// 打开媒体 / 切换到新媒体。
  AutoPlayDecision onMediaOpened({required bool isVideo}) {
    _active = true;
    if (!_canAdvance) return AutoPlayDecision.cancelTimer;
    return isVideo
        ? AutoPlayDecision.cancelTimer
        : AutoPlayDecision.schedulePhotoTimer;
  }

  /// 手动上一项/下一项。
  AutoPlayDecision onManualSwitch({required bool isVideo}) {
    _active = true;
    if (!_canAdvance) return AutoPlayDecision.cancelTimer;
    return isVideo
        ? AutoPlayDecision.cancelTimer
        : AutoPlayDecision.schedulePhotoTimer;
  }

  /// 照片计时到期。
  AutoPlayDecision onPhotoTimerFired() {
    if (!_canAdvance || !_active) return AutoPlayDecision.none;
    return AutoPlayDecision.advanceNext;
  }

  /// 视频播放结束。
  AutoPlayDecision onVideoEnded() {
    if (!_canAdvance || !_active) return AutoPlayDecision.none;
    return AutoPlayDecision.advanceNext;
  }

  AutoPlayDecision onPause() {
    _paused = true;
    return AutoPlayDecision.cancelTimer;
  }

  AutoPlayDecision onResume({required bool isVideo}) {
    _paused = false;
    if (!_canAdvance) return AutoPlayDecision.none;
    return isVideo
        ? AutoPlayDecision.none
        : AutoPlayDecision.schedulePhotoTimer;
  }

  AutoPlayDecision onBackground() {
    _background = true;
    return AutoPlayDecision.cancelTimer;
  }

  AutoPlayDecision onForeground({required bool isVideo}) {
    _background = false;
    if (!_canAdvance) return AutoPlayDecision.none;
    return isVideo
        ? AutoPlayDecision.none
        : AutoPlayDecision.schedulePhotoTimer;
  }

  /// Viewer 关闭。
  AutoPlayDecision onClose() {
    _active = false;
    return AutoPlayDecision.cancelTimer;
  }
}
