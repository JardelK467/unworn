class AppConstants {
  AppConstants._();

  static const String appName = 'UNWORN';
  static const String tagline = 'Your. Garment. Reimagined.';
  static const String loadingMessage = 'Finding its next life...';

  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String geminiModel = 'gemini-2.5-flash';
  static const String geminiImageModel = 'gemini-2.5-flash-image';
}
