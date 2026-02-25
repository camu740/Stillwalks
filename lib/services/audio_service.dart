import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service to manage background music playback.
/// Volume is independent of device volume (controlled in-app).
class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  double _volume = 0.5;
  bool _isPlaying = false;
  bool _initialized = false;

  double get volume => _volume;
  bool get isPlaying => _isPlaying;

  /// Initialize and start playing the background music in loop.
  Future<void> initialize({double volume = 0.5}) async {
    if (_initialized) return;

    _volume = volume.clamp(0.0, 1.0);

    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_volume);
      await _player.play(AssetSource('sounds/en-mis-suenos.ogg'));
      _isPlaying = true;
      _initialized = true;
      debugPrint('🎵 AudioService: Music started (volume: ${(_volume * 100).round()}%)');
    } catch (e) {
      debugPrint('❌ AudioService: Error initializing music: $e');
    }
  }

  /// Set volume (0.0 to 1.0) — independent of device volume.
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    notifyListeners();
  }

  /// Pause music (e.g. when app goes to background).
  Future<void> pause() async {
    if (_isPlaying) {
      await _player.pause();
      _isPlaying = false;
    }
  }

  /// Resume music (e.g. when app returns to foreground).
  Future<void> resume() async {
    if (!_isPlaying && _initialized) {
      await _player.resume();
      _isPlaying = true;
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
