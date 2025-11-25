import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:millionaire_quiz/providers/game_provider.dart';
import 'package:millionaire_quiz/constants/constants.dart';
import 'package:millionaire_quiz/utils/translations.dart';

class PrizeLadderWidget extends StatelessWidget {
  const PrizeLadderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final language = gameProvider.language;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        children: [
          Text(
            Translations.get('prizes', language),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.amber[300],
            ),
          ),
          const SizedBox(height: 16),
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return Column(
                children: GameConstants.prizeLevels.reversed.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final prize = entry.value;
                  final levelIndex = GameConstants.prizeLevels.length - 1 - index;
                  final isActive = levelIndex == gameProvider.currentLevel;
                  final isPassed = levelIndex < gameProvider.currentLevel;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? Colors.amber[400]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive 
                            ? Colors.amber[400]!
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${levelIndex + 1}.',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isActive 
                                ? const Color(0xFF0F172A)
                                : isPassed
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            prize,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive 
                                  ? const Color(0xFF0F172A)
                                  : isPassed
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.8),
                              decoration: isPassed ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

