import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_config.dart';

class EnvironmentConfig {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  // ========== SENSÍVEIS (do .env) ==========
  static String get projectId => dotenv.get('FIREBASE_PROJECT_ID', fallback: '');
  static String get androidAppId => dotenv.get('FIREBASE_ANDROID_APP_ID', fallback: '');
  static String get iosAppId => dotenv.get('FIREBASE_IOS_APP_ID', fallback: '');
  static String get apiKey => dotenv.get('FIREBASE_API_KEY', fallback: '');
  static String get authDomain => dotenv.get('FIREBASE_AUTH_DOMAIN', fallback: '');
  static String get databaseUrl => dotenv.get('FIREBASE_DATABASE_URL', fallback: '');
  static String get storageBucket => dotenv.get('FIREBASE_STORAGE_BUCKET', fallback: '');
  static String get messagingSenderId => dotenv.get('FIREBASE_MESSAGING_SENDER_ID', fallback: '');
  static String get measurementId => dotenv.get('FIREBASE_MEASUREMENT_ID', fallback: '');
  static String get geminiApiKey => dotenv.get('GEMINI_API_KEY', fallback: '');

  // ========== NÃO SENSÍVEIS (do AppConfig) ==========
  static String get geminiModel => AppConfig.geminiModel;
  static bool get enableGeminiLogs => AppConfig.enableGeminiLogs;
  static bool get enableCrashlytics => AppConfig.enableCrashlytics;
  static bool get enableAnalytics => AppConfig.enableAnalytics;
  static String get androidPackageName => AppConfig.androidPackageName;
  static String get iosBundleId => AppConfig.iosBundleId;

  // Validation
  static bool get isValid {
    return projectId.isNotEmpty &&
        androidAppId.isNotEmpty &&
        iosAppId.isNotEmpty;
  }

  static Map<String, String> get firebaseOptions => {
    'projectId': projectId,
    'androidAppId': androidAppId,
    'iosAppId': iosAppId,
    'apiKey': apiKey,
    'authDomain': authDomain,
    'databaseUrl': databaseUrl,
    'storageBucket': storageBucket,
    'messagingSenderId': messagingSenderId,
    'measurementId': measurementId,
  };
}