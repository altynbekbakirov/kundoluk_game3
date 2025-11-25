import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:millionaire_quiz/providers/game_provider.dart';
import 'package:millionaire_quiz/constants/constants.dart';
import 'package:millionaire_quiz/utils/translations.dart';

class GameOverWidget extends StatelessWidget {
  const GameOverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final currentLevel = gameProvider.currentLevel;
        final isAnswerCorrect = gameProvider.isAnswerCorrect;
        final language = gameProvider.language;
        
        final wonPrize = currentLevel > 0 && isAnswerCorrect != false 
            ? GameConstants.prizeLevels[currentLevel] 
            : currentLevel > 0 
                ? GameConstants.prizeLevels[currentLevel - 1] 
                : "0 ${Translations.get('som', language)}";
        
        final isWinner = currentLevel == GameConstants.prizeLevels.length - 1 && 
                        isAnswerCorrect == true;

        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isWinner 
                    ? Translations.get('congratulationsWinner', language)
                    : Translations.get('gameOverTitle', language),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[300],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isWinner 
                    ? '${Translations.get('youWonGrandPrize', language)} ${GameConstants.prizeLevels[GameConstants.prizeLevels.length - 1]}!'
                    : '${Translations.get('yourWinnings', language)} $wonPrize',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  gameProvider.playAgain();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[400],
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 8,
                ),
                child: Text(Translations.get('playAgain', language)),
              ),
            ],
          ),
        );
      },
    );
  }
}


