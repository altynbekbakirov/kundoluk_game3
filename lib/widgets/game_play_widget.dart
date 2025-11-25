import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:millionaire_quiz/providers/game_provider.dart';
import 'package:millionaire_quiz/widgets/lifelines_widget.dart';
import 'package:millionaire_quiz/widgets/question_display_widget.dart';
import 'package:millionaire_quiz/widgets/prize_ladder_widget.dart';
import 'package:millionaire_quiz/utils/translations.dart';

class GamePlayWidget extends StatelessWidget {
  const GamePlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 900;
    
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final language = gameProvider.language;
        
        if (gameProvider.currentQuestion == null) {
          return Center(
            child: Text(
              Translations.get('errorMessage', language),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const LifelinesWidget(),
              const SizedBox(height: 16),
              if (isWideScreen)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: QuestionDisplayWidget(
                        question: gameProvider.currentQuestion!,
                        onAnswerSelect: gameProvider.selectAnswer,
                        gameProvider: gameProvider,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      flex: 1,
                      child: PrizeLadderWidget(),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    QuestionDisplayWidget(
                      question: gameProvider.currentQuestion!,
                      onAnswerSelect: gameProvider.selectAnswer,
                      gameProvider: gameProvider,
                    ),
                    const SizedBox(height: 16),
                    const PrizeLadderWidget(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

