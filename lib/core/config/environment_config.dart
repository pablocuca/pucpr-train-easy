import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  // Firebase Configuration
  static String get projectId => dotenv.get('FIREBASE_PROJECT_ID', fallback: '');
  static String get androidAppId => dotenv.get('FIREBASE_ANDROID_APP_ID', fallback: '');
  static String get iosAppId => dotenv.get('FIREBASE_IOS_APP_ID', fallback: '');
  static String get webAppId => dotenv.get('FIREBASE_WEB_APP_ID', fallback: '');
  static String get apiKey => dotenv.get('FIREBASE_API_KEY', fallback: '');
  static String get authDomain => dotenv.get('FIREBASE_AUTH_DOMAIN', fallback: '');
  static String get databaseUrl => dotenv.get('FIREBASE_DATABASE_URL', fallback: '');
  static String get storageBucket => dotenv.get('FIREBASE_STORAGE_BUCKET', fallback: '');
  static String get messagingSenderId => dotenv.get('FIREBASE_MESSAGING_SENDER_ID', fallback: '');
  static String get measurementId => dotenv.get('FIREBASE_MEASUREMENT_ID', fallback: '');

  // Platform Configuration
  static String get androidPackageName => dotenv.get('ANDROID_PACKAGE_NAME', fallback: 'com.example.traineasy');
  static String get iosBundleId => dotenv.get('IOS_BUNDLE_ID', fallback: 'com.example.traineasy');

  // Validation
  static bool get isValid {
    return projectId.isNotEmpty && 
           androidAppId.isNotEmpty && 
           iosAppId.isNotEmpty && 
           webAppId.isNotEmpty;
  }

  static Map<String, String> get firebaseOptions => {
    'projectId': projectId,
    'androidAppId': androidAppId,
    'iosAppId': iosAppId,
    'webAppId': webAppId,
    'apiKey': apiKey,
    'authDomain': authDomain,
    'databaseUrl': databaseUrl,
    'storageBucket': storageBucket,
    'messagingSenderId': messagingSenderId,
    'measurementId': measurementId,
  };
}