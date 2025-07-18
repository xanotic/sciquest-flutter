import 'package:flutter/services.dart';
// import 'package:audioplayers/audioplayers.dart'; // REMOVED: Import audioplayers

class AudioService {
  static final AudioService instance = AudioService._init();
  AudioService._init();

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  // final AudioPlayer _backgroundPlayer = AudioPlayer(); // REMOVED: Dedicated player for background music

  Future<void> initialize() async {
    // Initialize audio system (no background music initialization needed)
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    // REMOVED: Control background music volume
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

  // REMOVED: dispose method for background music player
  // void dispose() {
  //   _backgroundPlayer.dispose();
  // }
}
