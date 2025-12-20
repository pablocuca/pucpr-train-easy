/// Configurações do app que NÃO são sensíveis
/// Este arquivo fica no git - edite livremente
class AppConfig {
  // AI Configuration
  static const String geminiModel = 'gemini-1.5-flash-latest';
  static const bool enableGeminiLogs = false;

  // Telemetry
  static const bool enableCrashlytics = true;
  static const bool enableAnalytics = true;

  // Platform IDs
  static const String androidPackageName = 'br.com.pablocustodio.traineasy';
  static const String iosBundleId = 'br.com.pablocustodio.traineasy';
}
