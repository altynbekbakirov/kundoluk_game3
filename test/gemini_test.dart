import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:millionaire_quiz/constants/constants.dart';

void main() async {
  final apiKey = GameConstants.geminiApiKey;
  print('Testing API Key: $apiKey');

  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: apiKey,
  );

  try {
    final prompt = 'Hello, are you working?';
    final response = await model.generateContent([Content.text(prompt)]);
    print('Response: ${response.text}');
  } catch (e) {
    print('Error: $e');
  }
}
