import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:millionaire_quiz/providers/game_provider.dart';
import 'package:millionaire_quiz/utils/translations.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final language = gameProvider.language;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Translations.get('title', language),
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600 ? 60 : 40,
            fontWeight: FontWeight.bold,
            color: Colors.amber[300],
            shadows: const [
              Shadow(
                offset: Offset(0, 4),
                blurRadius: 4,
                color: Colors.black45,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          Translations.get('subtitle', language),
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600 ? 24 : 20,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            context.read<GameProvider>().startGame();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[400],
            foregroundColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
          ),
          child: Text(Translations.get('startGame', language)),
        ),
      ],
    );
  }
}

