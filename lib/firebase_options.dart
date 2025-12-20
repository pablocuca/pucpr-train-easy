import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'core/config/environment_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: EnvironmentConfig.apiKey,
    appId: EnvironmentConfig.androidAppId,
    messagingSenderId: EnvironmentConfig.messagingSenderId,
    projectId: EnvironmentConfig.projectId,
    databaseURL: EnvironmentConfig.databaseUrl,
    storageBucket: EnvironmentConfig.storageBucket,
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: EnvironmentConfig.apiKey,
    appId: EnvironmentConfig.iosAppId,
    messagingSenderId: EnvironmentConfig.messagingSenderId,
    projectId: EnvironmentConfig.projectId,
    databaseURL: EnvironmentConfig.databaseUrl,
    storageBucket: EnvironmentConfig.storageBucket,
    iosBundleId: EnvironmentConfig.iosBundleId,
  );
}
