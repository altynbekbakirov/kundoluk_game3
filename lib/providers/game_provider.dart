import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:millionaire_quiz/models/game_state.dart';
import 'package:millionaire_quiz/models/question.dart';
import 'package:millionaire_quiz/models/lifelines.dart';
import 'package:millionaire_quiz/services/gemini_service.dart';
import 'package:millionaire_quiz/services/sound_service.dart';
import 'package:millionaire_quiz/constants/constants.dart';
import 'package:millionaire_quiz/utils/translations.dart';

class GameProvider with ChangeNotifier {
  GameState _gameState = GameState.menu;
  int _currentLevel = 0;
  Question? _currentQuestion;
  String? _selectedAnswer;
  bool? _isAnswerCorrect;
  Lifelines _lifelines = Lifelines();
  List<String> _disabledOptions = [];
  String? _modalContent;
  int _timeLeft = GameConstants.timerDuration;
  bool _timerActive = false;
  bool _soundEnabled = true;
  String _language = 'ky'; // Default language is Kyrgyz
  
  Timer? _timer;
  final GeminiService _geminiService = GeminiService();
  final SoundService _soundService = SoundService();

  // Getters
  GameState get gameState => _gameState;
  int get currentLevel => _currentLevel;
  Question? get currentQuestion => _currentQuestion;
  String? get selectedAnswer => _selectedAnswer;
  bool? get isAnswerCorrect => _isAnswerCorrect;
  Lifelines get lifelines => _lifelines;
  List<String> get disabledOptions => _disabledOptions;
  String? get modalContent => _modalContent;
  int get timeLeft => _timeLeft;
  bool get timerActive => _timerActive;
  bool get soundEnabled => _soundEnabled;
  String get language => _language;

  GameProvider() {
    _initialize();
  }

  void _initialize() {
    _geminiService.initialize();
    _soundService.initialize();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soundService.dispose();
    super.dispose();
  }

  Future<void> fetchQuestion() async {
    if (_currentLevel >= GameConstants.prizeLevels.length) {
      _gameState = GameState.gameOver;
      notifyListeners();
      return;
    }

    _gameState = GameState.loading;
    _disabledOptions.clear();
    _stopTimer();
    notifyListeners();

    try {
      final question = await _geminiService.generateQuestion(_currentLevel, _language);
      _currentQuestion = question;
      _selectedAnswer = null;
      _isAnswerCorrect = null;
      _timeLeft = GameConstants.timerDuration;
      _gameState = GameState.playing;
      _startTimer();
      
      _soundService.playQuestionAppear();
      
      // Start thinking music after question appears
      Future.delayed(const Duration(seconds: 1), () {
        _soundService.startThinkingMusic();
      });
      
      notifyListeners();
    } catch (error) {
      print('Error fetching question: $error');
      _gameState = GameState.gameOver;
      notifyListeners();
    }
  }

  void resetGame() {
    _soundService.stopThinkingMusic();
    _gameState = GameState.menu;
    _currentQuestion = null;
    _currentLevel = 0;
    _lifelines.reset();
    _modalContent = null;
    _disabledOptions.clear();
    _stopTimer();
    _timeLeft = GameConstants.timerDuration;
    notifyListeners();
  }

  Future<void> startGame() async {
    resetGame();
    _soundService.playGameStart();
    
    // Small delay to allow state to reset before fetching
    await Future.delayed(const Duration(milliseconds: 100));
    _currentLevel = 0;
    fetchQuestion();
  }

  void playAgain() {
    resetGame();
  }

  Future<void> selectAnswer(String answer) async {
    if (_gameState != GameState.playing || _currentQuestion == null) return;
    
    _stopTimer();
    _soundService.stopThinkingMusic();
    _gameState = GameState.answered;
    _selectedAnswer = answer;
    final correct = answer == _currentQuestion!.correctAnswer;
    _isAnswerCorrect = correct;
    
    _soundService.playAnswerSelect();
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));

    if (correct) {
      _soundService.playCorrectAnswer();
      if (_currentLevel == GameConstants.prizeLevels.length - 1) {
        await Future.delayed(const Duration(seconds: 1));
        _soundService.playVictory();
        _gameState = GameState.gameOver;
      } else {
        await Future.delayed(const Duration(seconds: 1));
        _soundService.playLevelUp();
        _currentLevel++;
        await Future.delayed(const Duration(seconds: 1));
        fetchQuestion();
        return;
      }
    } else {
      _soundService.playWrongAnswer();
      await Future.delayed(const Duration(seconds: 1));
      _soundService.playGameOver();
      _gameState = GameState.gameOver;
    }
    
    notifyListeners();
  }

  void _startTimer() {
    _timerActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_timerActive || _gameState != GameState.playing) {
        timer.cancel();
        return;
      }

      if (_timeLeft <= 0) {
        _onTimeUp();
        timer.cancel();
        return;
      }

      // Play warning sounds for last 10 seconds
      if (_timeLeft <= 10) {
        _soundService.playTimerTick();
      } else if (_timeLeft == 15) {
        _soundService.playTimerWarning();
      }

      _timeLeft--;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timerActive = false;
    _timer?.cancel();
  }

  Future<void> _onTimeUp() async {
    _timerActive = false;
    _soundService.stopThinkingMusic();
    _gameState = GameState.answered;
    _selectedAnswer = null;
    _isAnswerCorrect = false;
    
    _soundService.playWrongAnswer();
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 3));
    _soundService.playGameOver();
    _gameState = GameState.gameOver;
    notifyListeners();
  }

  // Lifeline methods
  void useFiftyFifty() {
    if (_currentQuestion == null || !_lifelines.fiftyFifty || _gameState != GameState.playing) return;
    
    _soundService.playLifelineUse();
    _lifelines = _lifelines.copyWith(fiftyFifty: false);
    
    final incorrectOptions = _currentQuestion!.options
        .where((opt) => opt != _currentQuestion!.correctAnswer)
        .toList();
    incorrectOptions.shuffle();
    _disabledOptions = [incorrectOptions[0], incorrectOptions[1]];
    
    notifyListeners();
  }

  void useCallFriend() {
    if (_currentQuestion == null || !_lifelines.callFriend || _gameState != GameState.playing) return;
    
    _soundService.playLifelineUse();
    _lifelines = _lifelines.copyWith(callFriend: false);

    final willBeCorrect = Random().nextDouble() <= 0.9; // 90% chance of being correct
    String friendAnswer;

    if (willBeCorrect) {
      friendAnswer = _currentQuestion!.correctAnswer;
    } else {
      final incorrectOptions = _currentQuestion!.options
          .where((opt) => opt != _currentQuestion!.correctAnswer)
          .toList();
      friendAnswer = incorrectOptions[Random().nextInt(incorrectOptions.length)];
    }

    _modalContent = '''
${Translations.get('callFriendTitle', _language)}

${Translations.get('callFriendText', _language)}

$friendAnswer

${Translations.get('callFriendEnd', _language)}
    ''';
    
    notifyListeners();
  }

  void useAudienceVote() {
    if (_currentQuestion == null || !_lifelines.audienceVote || _gameState != GameState.playing) return;
    
    _soundService.playLifelineUse();
    _lifelines = _lifelines.copyWith(audienceVote: false);

    final options = _currentQuestion!.options;
    final correctAnswer = _currentQuestion!.correctAnswer;
    final votes = <String, int>{};
    
    for (final option in options) {
      votes[option] = 0;
    }
    
    int totalVotes = 100;
    // Guarantee correct answer has at least 45%
    const baseCorrect = 45;
    votes[correctAnswer] = baseCorrect;
    totalVotes -= baseCorrect;
    
    // Distribute the rest randomly
    for (int i = 0; i < totalVotes; i++) {
      final randomOption = options[Random().nextInt(options.length)];
      votes[randomOption] = votes[randomOption]! + 1;
    }

    final voteResults = options.map((option) => {
      'option': option,
      'percentage': votes[option]!,
    }).toList()
      ..sort((a, b) => (b['percentage'] as int).compareTo(a['percentage'] as int));

    String resultText = '${Translations.get('audienceVoteTitle', _language)}\n\n';
    for (final result in voteResults) {
      resultText += '${result['percentage']}% - ${result['option']}\n';
    }

    _modalContent = resultText;
    notifyListeners();
  }

  void closeModal() {
    _modalContent = null;
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = _soundService.toggleSound();
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }
}

