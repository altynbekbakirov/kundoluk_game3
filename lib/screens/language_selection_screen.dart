import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:millionaire_quiz/providers/game_provider.dart';
import 'package:millionaire_quiz/screens/game_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Тилди тандаңыз / Выберите язык',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width > 600 ? 36 : 28,
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
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLanguageButton(
                        context,
                        language: 'ky',
                        icon: Icons.circle,
                        label: 'Кыргызча',
                        color: const Color(0xFFDC143C),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width > 600 ? 60 : 40),
                      _buildLanguageButton(
                        context,
                        language: 'ru',
                        icon: Icons.circle,
                        label: 'Русский',
                        color: const Color(0xFF4A7FDC),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context, {
    required String language,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final size = MediaQuery.of(context).size.width > 600 ? 160.0 : 120.0;

    return GestureDetector(
      onTap: () {
        context.read<GameProvider>().setLanguage(language);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GameScreen(),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(
                color: color,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  context.read<GameProvider>().setLanguage(language);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const GameScreen(),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Horizontal lines (latitude)
                    CustomPaint(
                      size: Size(size, size),
                      painter: _GlobePainter(color: color),
                    ),
                    // Globe icon
                    Icon(
                      Icons.language,
                      size: size * 0.6,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600 ? 26 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GlobePainter extends CustomPainter {
  final Color color;

  _GlobePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw horizontal lines (latitude)
    for (double i = -0.6; i <= 0.6; i += 0.3) {
      final y = center.dy + (radius * i);
      final width = radius * (1 - (i.abs() / 0.8));
      canvas.drawLine(
        Offset(center.dx - width, y),
        Offset(center.dx + width, y),
        paint,
      );
    }

    // Draw vertical line (longitude)
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    // Draw curved vertical lines
    final path1 = Path();
    final path2 = Path();

    for (double t = -1; t <= 1; t += 0.05) {
      final angle = t * 3.14159 / 2;
      final x1 = center.dx + radius * 0.4 * Math.cos(angle);
      final y = center.dy + radius * Math.sin(angle);
      final x2 = center.dx - radius * 0.4 * Math.cos(angle);

      if (t == -1) {
        path1.moveTo(x1, y);
        path2.moveTo(x2, y);
      } else {
        path1.lineTo(x1, y);
        path2.lineTo(x2, y);
      }
    }

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

