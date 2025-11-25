import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:millionaire_quiz/providers/game_provider.dart';
import 'package:millionaire_quiz/models/game_state.dart';
import 'package:millionaire_quiz/utils/translations.dart';

class LifelinesWidget extends StatelessWidget {
  const LifelinesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final isInteractionDisabled = gameProvider.gameState == GameState.answered;
        final language = gameProvider.language;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LifelineButton(
              icon: const Text(
                '50/50',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              isUsed: !gameProvider.lifelines.fiftyFifty,
              isDisabled: isInteractionDisabled,
              onPressed: gameProvider.useFiftyFifty,
              label: Translations.get('lifeline5050', language),
            ),
            const SizedBox(width: 12),
            _LifelineButton(
              icon: const Icon(Icons.phone, size: 24),
              isUsed: !gameProvider.lifelines.callFriend,
              isDisabled: isInteractionDisabled,
              onPressed: gameProvider.useCallFriend,
              label: Translations.get('lifelineCallFriend', language),
            ),
            const SizedBox(width: 12),
            _LifelineButton(
              icon: const Icon(Icons.pie_chart, size: 24),
              isUsed: !gameProvider.lifelines.audienceVote,
              isDisabled: isInteractionDisabled,
              onPressed: gameProvider.useAudienceVote,
              label: Translations.get('lifelineAudience', language),
            ),
          ],
        );
      },
    );
  }
}

class _LifelineButton extends StatelessWidget {
  final Widget icon;
  final bool isUsed;
  final bool isDisabled;
  final VoidCallback onPressed;
  final String label;

  const _LifelineButton({
    required this.icon,
    required this.isUsed,
    required this.isDisabled,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (isUsed || isDisabled) ? null : onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 64,
              decoration: BoxDecoration(
                color: isUsed 
                    ? Colors.grey.shade800.withOpacity(0.3)
                    : Colors.amber.shade700.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUsed 
                      ? Colors.grey.shade700.withOpacity(0.5)
                      : Colors.amber.shade400,
                  width: 2,
                ),
                boxShadow: isUsed 
                    ? null 
                    : [
                        BoxShadow(
                          color: Colors.amber.shade400.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isUsed ? 0.3 : 1.0,
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: isUsed ? Colors.grey.shade600 : Colors.amber.shade300,
                      decoration: isUsed ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.grey.shade600,
                      decorationThickness: 2,
                    ),
                    child: IconTheme(
                      data: IconThemeData(
                        color: isUsed ? Colors.grey.shade600 : Colors.amber.shade300,
                      ),
                      child: icon,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


