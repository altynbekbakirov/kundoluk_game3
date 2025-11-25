import 'dart:async';

/// Sound service stub - all sound methods are no-ops
/// This allows the app to function without audio dependencies
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _enabled = true;
  Timer? _thinkingMusicTimer;

  bool get isEnabled => _enabled;

  Future<void> initialize() async {
    // No-op: No audio initialization needed
  }

  void dispose() {
    _thinkingMusicTimer?.cancel();
  }

  // All sound methods are now no-ops (do nothing)
  
  Future<void> playGameStart() async {
    // No-op
  }

  Future<void> playQuestionAppear() async {
    // No-op
  }

  Future<void> playAnswerSelect() async {
    // No-op
  }

  Future<void> playCorrectAnswer() async {
    // No-op
  }

  Future<void> playWrongAnswer() async {
    // No-op
  }

  Future<void> playTimerWarning() async {
    // No-op
  }

  Future<void> playTimerTick() async {
    // No-op
  }

  Future<void> playLifelineUse() async {
    // No-op
  }

  Future<void> playGameOver() async {
    // No-op
  }

  Future<void> playVictory() async {
    // No-op
  }

  Future<void> playLevelUp() async {
    // No-op
  }

  Future<void> startThinkingMusic() async {
    // No-op
  }

  void stopThinkingMusic() {
    _thinkingMusicTimer?.cancel();
    _thinkingMusicTimer = null;
  }

  bool toggleSound() {
    _enabled = !_enabled;
    if (!_enabled) {
      stopThinkingMusic();
    }
    return _enabled;
  }
}
