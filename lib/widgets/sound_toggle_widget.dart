import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:millionaire_quiz/providers/game_provider.dart';

class SoundToggleWidget extends StatelessWidget {
  const SoundToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: gameProvider.toggleSound,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade600),
                ),
                child: Icon(
                  gameProvider.soundEnabled 
                      ? Icons.volume_up 
                      : Icons.volume_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


