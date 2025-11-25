import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:millionaire_quiz/providers/game_provider.dart';
import 'package:millionaire_quiz/screens/language_selection_screen.dart';
import 'package:millionaire_quiz/constants/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // API key is now passed via --dart-define at build time
  // This is more secure than bundling .env in assets
  final apiKey = GameConstants.geminiApiKey;
  print('🔑 API Key configured: ${apiKey.isNotEmpty ? "YES" : "NO"}');
  if (apiKey.isNotEmpty) {
    print('✅ API key length: ${apiKey.length}');
  } else {
    print('⚠️ WARNING: API key not provided. App will use fallback questions.');
    print('💡 Build with: flutter build apk --dart-define=GEMINI_API_KEY=your_key');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'Миллионер болгуң келеби?',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          fontFamily: 'Roboto',
        ),
        home: const LanguageSelectionScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

