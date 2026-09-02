/// TV 遥控器左右键长按快进/快退状态机（PRD §0-3 / §8.3）。
///
/// ```text
/// DOWN → 等待 longPressThreshold
///   ├─ 阈值前 UP → tap（上一项/下一项）
///   └─ 超过阈值 → seeking mode
///         每隔 repeatInterval 触发一次 seek
///         步长随持续时间递增 10s → 30s → 60s
///       UP → exit seeking mode
/// ```
class TvSeekLogic {
  TvSeekLogic({
    this.longPressThreshold = const Duration(milliseconds: 450),
    this.repeatInterval = const Duration(milliseconds: 180),
    this.escalateAfter = const Duration(milliseconds: 1500),
    this.steps = const [
      Duration(seconds: 10),
      Duration(seconds: 30),
      Duration(seconds: 60),
    ],
  });

  final Duration longPressThreshold;
  final Duration repeatInterval;
  final Duration escalateAfter;
  final List<Duration> steps;

  DateTime? _downAt;
  Duration _direction = Duration.zero;
  DateTime? _lastSeekAt;
  bool _seeking = false;

  /// 是否处于 seeking mode（禁用媒体切换）。
  bool get isSeeking => _seeking;

  bool get _active => _downAt != null;

  /// 按下。
  void onDown({required bool forward, required DateTime now}) {
    _downAt = now;
    _direction = forward
        ? const Duration(seconds: 1)
        : const Duration(seconds: -1);
    _lastSeekAt = null;
    _seeking = false;
  }

  /// 按住期间的重复事件。返回本次 seek 量（正=快进 / 负=快退），未触发返回 null。
  Duration? onRepeat(DateTime now) {
    if (!_active) return null;
    final elapsed = now.difference(_downAt!);
    if (elapsed < longPressThreshold) return null;

    _seeking = true;
    final last = _lastSeekAt;
    if (last != null && now.difference(last) < repeatInterval) return null;

    // 步长按持续时间逐级递增。
    final level =
        ((elapsed - longPressThreshold).inMilliseconds ~/
                escalateAfter.inMilliseconds)
            .clamp(0, steps.length - 1);
    _lastSeekAt = now;
    return _direction * steps[level].inSeconds;
  }

  /// 抬起。返回 true 表示这是一次短按（tap：上一项/下一项），false 表示长按（已 seek）。
  bool onUp() {
    final wasTap = !_seeking && _active;
    _downAt = null;
    _direction = Duration.zero;
    _lastSeekAt = null;
    _seeking = false;
    return wasTap;
  }

  void reset() {
    _downAt = null;
    _seeking = false;
    _lastSeekAt = null;
  }
}
