import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:millionaire_quiz/providers/game_provider.dart';
import 'package:millionaire_quiz/models/game_state.dart';
import 'package:millionaire_quiz/widgets/menu_widget.dart';
import 'package:millionaire_quiz/widgets/loading_widget.dart';
import 'package:millionaire_quiz/widgets/game_play_widget.dart';
import 'package:millionaire_quiz/widgets/game_over_widget.dart';
import 'package:millionaire_quiz/widgets/modal_widget.dart';
import 'package:millionaire_quiz/utils/translations.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A), // slate-900
              Color(0xFF312E81), // indigo-900
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      final language = gameProvider.language;
                      switch (gameProvider.gameState) {
                        case GameState.menu:
                          return const MenuWidget();
                        case GameState.loading:
                          return LoadingWidget(text: Translations.get('loading', language));
                        case GameState.playing:
                        case GameState.answered:
                          return const GamePlayWidget();
                        case GameState.gameOver:
                          return const GameOverWidget();
                      }
                    },
                  ),
                ),
              ),
              Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  if (gameProvider.modalContent != null) {
                    return ModalWidget(
                      content: gameProvider.modalContent!,
                      onClose: gameProvider.closeModal,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

