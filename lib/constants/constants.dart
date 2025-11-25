class GameConstants {
  static const List<String> prizeLevels = [
    "1,000 сом",
    "2,000 сом",
    "5,000 сом",
    "10,000 сом",
    "20,000 сом",
    "50,000 сом",
    "75,000 сом",
    "150,000 сом",
    "250,000 сом",
    "500,000 сом",
    "1,000,000 сом"
  ];

  static const int timerDuration = 30; // seconds
  
  // API key passed at compile time via --dart-define
  // This is more secure than bundling .env in assets
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  
  static const List<String> optionLetters = ['A', 'B', 'C', 'D'];
  
  static const List<String> subjects = [
    "Математика",
    "Биология",
    "Кыргызстан тарыхы",
    "Дүйнөлүк тарых",
    "География",
    "Кыргыз адабияты",
    "Дүйнөлүк адабият",
    "Физика",
    "Химия",
    "Информатика"
  ];
}

