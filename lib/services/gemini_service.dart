import 'dart:convert';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:millionaire_quiz/models/question.dart';
import 'package:millionaire_quiz/constants/constants.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late final GenerativeModel _model;

  void initialize() {
    final apiKey = GameConstants.geminiApiKey;
    
    // Debug logging
    print('🔑 Gemini API Key length: ${apiKey.length}');
    if (apiKey.isEmpty) {
      print('⚠️  WARNING: API key is empty! Using fallback questions.');
    } else {
      print('✅ API key loaded successfully');
    }
    
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.1,
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<Question> generateQuestion(int level, String language) async {
    try {
      // Map game level (0-6) to school grade (5-11) with minimum grade 5
      final gradeLevel = (level + 5).clamp(5, 11);
      final randomSubject = GameConstants.subjects[Random().nextInt(GameConstants.subjects.length)];

      final prompt = language == 'ru' 
          ? '''
        Вы ведущий интеллектуальной викторины для умных школьников. Ваша задача - создать один интересный вопрос с множественным выбором на русском языке.
        Вопрос должен быть по предмету $randomSubject из школьной программы Кыргызстана.
        Вопрос должен быть сложным для ученика $gradeLevel класса Кыргызстана, подходящим для викторины в стиле "Кто хочет стать миллионером", где вопросы постепенно усложняются. Это не должен быть простой или очень известный вопрос для этого класса.
        У вопроса должно быть 4 варианта ответа, где неправильные варианты (дистракторы) правдоподобны, но явно неверны.
        Вы должны определить правильный ответ.

        Предоставьте результат ТОЛЬКО в формате JSON, схема:
        {
          "question": "текст вопроса на русском языке",
          "options": ["4 варианта ответа на русском языке"],
          "correctAnswer": "правильный ответ, один из списка options"
        }
      '''
          : '''
        Сиз акылдуу мектеп окуучулары үчүн интеллектуалдык викторина оюнунун алып баруучусусуз. Сиздин милдетиңиз кыргыз тилинде ой козгогуч, көп тандоолуу бир суроо түзүү.
        Суроо $randomSubject предметинен болушу керек.
        Кыргызстандын $gradeLevel-класс окуучусу үчүн татаал болушу керек, "миллионер" стилиндеги викторина оюнуна ылайыктуу, мында суроолор акырындап татаалдашат. Бул класс үчүн жөнөкөй же абдан белгилүү суроо болбошу керек.
        Суроого 4 жооп варианты болушу керек, мында туура эмес варианттар (алаксытуучулар) ишенимдүү, бирок ачык түрдө туура эмес болушу керек.
        Сиз туура жоопту аныкташыңыз керек.

        JSON форматында гана жыйынтык бериңиз, schema:
        {
          "question": "суроо тексти кыргыз тилинде",
          "options": ["4 жооп варианты кыргыз тилинде"],
          "correctAnswer": "туура жооп, options тизмесинен бири"
        }
      ''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonString = response.text ?? '';
      
      final Map<String, dynamic> parsedJson = jsonDecode(jsonString);
      
      // Validate that the correct answer is one of the options
      final options = List<String>.from(parsedJson['options']);
      final correctAnswer = parsedJson['correctAnswer'] as String;
      
      if (!options.contains(correctAnswer)) {
        throw Exception('Validation Error: Correct answer not found in options');
      }

      return Question.fromJson(parsedJson);
    } catch (error) {
      print('Error generating question from Gemini: $error');
      // Retry once on error
      if (error.toString().contains('Validation Error')) {
        return generateQuestion(level, language);
      }
      
      // Fallback question based on language
      return language == 'ru' 
          ? Question(
              question: 'Какой город является столицей Кыргызстана?',
              options: ['Бишкек', 'Ош', 'Джалал-Абад', 'Каракол'],
              correctAnswer: 'Бишкек',
            )
          : Question(
              question: 'Кыргызстандын борбору кайсы шаар?',
              options: ['Бишкек', 'Ош', 'Жалал-Абад', 'Каракол'],
              correctAnswer: 'Бишкек',
            );
    }
  }
}

