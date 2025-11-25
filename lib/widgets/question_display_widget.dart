import 'package:flutter/material.dart';
import 'package:millionaire_quiz/models/question.dart';
import 'package:millionaire_quiz/models/game_state.dart';
import 'package:millionaire_quiz/providers/game_provider.dart';
import 'package:millionaire_quiz/constants/constants.dart';
import 'package:millionaire_quiz/utils/translations.dart';

class QuestionDisplayWidget extends StatelessWidget {
  final Question question;
  final Function(String) onAnswerSelect;
  final GameProvider gameProvider;

  const QuestionDisplayWidget({
    super.key,
    required this.question,
    required this.onAnswerSelect,
    required this.gameProvider,
  });

  Color _getButtonColor(String option) {
    final isDisabledByLifeline = gameProvider.disabledOptions.contains(option);

    if (isDisabledByLifeline) {
      return Colors.grey.shade800.withOpacity(0.3);
    }

    if (gameProvider.gameState != GameState.answered) {
      return Colors.grey.shade800;
    }

    final isCorrect = option == question.correctAnswer;
    final isSelected = option == gameProvider.selectedAnswer;

    if (isCorrect) {
      return Colors.green.shade600;
    }
    if (isSelected && !isCorrect) {
      return Colors.red.shade600;
    }
    return Colors.grey.shade800.withOpacity(0.5);
  }

  Color _getBorderColor(String option) {
    final isDisabledByLifeline = gameProvider.disabledOptions.contains(option);

    if (isDisabledByLifeline) {
      return Colors.grey.shade600.withOpacity(0.3);
    }

    if (gameProvider.gameState != GameState.answered) {
      return Colors.grey.shade600;
    }

    final isCorrect = option == question.correctAnswer;
    final isSelected = option == gameProvider.selectedAnswer;

    if (isCorrect) {
      return Colors.green.shade400;
    }
    if (isSelected && !isCorrect) {
      return Colors.red.shade400;
    }
    return Colors.grey.shade600.withOpacity(0.5);
  }

  Color _getTimerColor() {
    if (gameProvider.timeLeft > 20) return Colors.green.shade400;
    if (gameProvider.timeLeft > 10) return Colors.amber.shade400;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Question and Timer Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: Column(
            children: [
              // Timer
              if (gameProvider.timerActive)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        color: _getTimerColor(),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${gameProvider.timeLeft}${Translations.get('seconds', gameProvider.language)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getTimerColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              // Question Text
              Text(
                question.question,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Answer Options
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: MediaQuery.of(context).size.width > 600 ? 4 : 6,
          ),
          itemCount: question.options.length,
          itemBuilder: (context, index) {
            final option = question.options[index];
            final letter = GameConstants.optionLetters[index];
            final isDisabledByLifeline = gameProvider.disabledOptions.contains(option);
            final isCorrect = option == question.correctAnswer;
            final isAnswered = gameProvider.gameState == GameState.answered;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: (gameProvider.gameState == GameState.answered || isDisabledByLifeline)
                      ? null
                      : () => onAnswerSelect(option),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getButtonColor(option),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getBorderColor(option),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: isDisabledByLifeline 
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: isDisabledByLifeline 
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (isAnswered && isCorrect)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        if (isAnswered && option == gameProvider.selectedAnswer && !isCorrect)
                          const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

