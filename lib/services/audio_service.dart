import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart'; // RE-ADDED: Import audioplayers

class AudioService {
  static final AudioService instance = AudioService._init();
  AudioService._init();

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  final AudioPlayer _backgroundPlayer =
      AudioPlayer(); // RE-ADDED: Dedicated player for background music

  Future<void> initialize() async {
    // Initialize audio system
    _backgroundPlayer.setReleaseMode(ReleaseMode.loop); // Loop background music
    await _backgroundPlayer
        .setVolume(_isMuted ? 0.0 : 0.5); // Set initial volume
    await _backgroundPlayer.play(
        AssetSource('audio/background_music.mp3')); // Play background music
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _backgroundPlayer
        .setVolume(_isMuted ? 0.0 : 0.5); // Control background music volume
  }

  Future<void> playButtonTap() async {
    if (!_isMuted) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> playCorrectAnswer() async {
    if (!_isMuted) {
      // Play correct answer sound
      SystemSound.play(SystemSoundType.click);
    }
  }

  Future<void> playWrongAnswer() async {
    if (!_isMuted) {
      // Play wrong answer sound
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> playQuizComplete() async {
    if (!_isMuted) {
      // Play quiz completion sound
      SystemSound.play(SystemSoundType.click);
    }
  }

  // ADDED: dispose method for background music player
  void dispose() {
    _backgroundPlayer.dispose();
  }
}
