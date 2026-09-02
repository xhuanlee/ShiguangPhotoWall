import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 播放设置（PRD §9）。
class PlaybackSettings {
  const PlaybackSettings({this.autoPlay = false, this.photoDurationSec = 2});

  final bool autoPlay;

  /// 照片停留时间：1~60 秒，默认 2 秒。
  final int photoDurationSec;

  PlaybackSettings copyWith({bool? autoPlay, int? photoDurationSec}) =>
      PlaybackSettings(
        autoPlay: autoPlay ?? this.autoPlay,
        photoDurationSec: photoDurationSec ?? this.photoDurationSec,
      );

  static PlaybackSettings fromPrefs(SharedPreferences prefs) {
    final duration = prefs.getInt(_kPhotoDuration) ?? 2;
    return PlaybackSettings(
      autoPlay: prefs.getBool(_kAutoPlay) ?? false,
      photoDurationSec: duration.clamp(1, 60),
    );
  }

  static const _kAutoPlay = 'settings.playback.autoPlay';
  static const _kPhotoDuration = 'settings.playback.photoDurationSec';
}

/// 播放设置存储（shared_preferences）。
class SettingsRepository extends ChangeNotifier {
  SettingsRepository(SharedPreferences prefs)
    : _prefs = prefs,
      _settings = PlaybackSettings.fromPrefs(prefs);

  final SharedPreferences _prefs;
  PlaybackSettings _settings;

  PlaybackSettings get settings => _settings;

  Future<void> setAutoPlay(bool value) async {
    await _prefs.setBool(PlaybackSettings._kAutoPlay, value);
    _settings = _settings.copyWith(autoPlay: value);
    notifyListeners();
  }

  Future<void> setPhotoDuration(int seconds) async {
    final clamped = seconds.clamp(1, 60);
    await _prefs.setInt(PlaybackSettings._kPhotoDuration, clamped);
    _settings = _settings.copyWith(photoDurationSec: clamped);
    notifyListeners();
  }
}
