import 'package:millionaire_quiz/services/gemini_service.dart';

void main() async {
  final service = GeminiService();
  service.initialize();

  final questions = <String>{};
  
  print('Fetching 10 questions...');
  
  for (var i = 0; i < 10; i++) {
    try {
      final question = await service.generateQuestion(1, 'ru');
      questions.add(question.question);
      print('Question $i: ${question.question}');
    } catch (e) {
      print('Error fetching question $i: $e');
    }
  }

  print('Unique questions received: ${questions.length}');
  
  if (questions.length > 1) {
    print('SUCCESS: Received multiple different questions.');
  } else {
    print('FAILURE: Received only ${questions.length} unique question(s).');
    throw Exception('Verification failed');
  }
}
