import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TelemetryService {
  static FirebaseAnalytics? _analytics;
  static bool _analyticsEnabled = false;
  static bool _crashlyticsEnabled = false;

  static Future<void> init({required bool enableAnalytics, required bool enableCrashlytics}) async {
    _analyticsEnabled = enableAnalytics;
    _crashlyticsEnabled = enableCrashlytics && !kIsWeb;
    if (_crashlyticsEnabled) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
    _analytics = FirebaseAnalytics.instance;
    await _analytics?.setAnalyticsCollectionEnabled(enableAnalytics);
  }

  static Future<void> setUser(String uid) async {
    if (_analyticsEnabled) {
      await _analytics?.setUserId(id: uid);
    }
    if (_crashlyticsEnabled) {
      await FirebaseCrashlytics.instance.setUserIdentifier(uid);
    }
  }

  static Future<void> trackEvent(String name, Map<String, Object> parameters) async {
    if (_analyticsEnabled) {
      await _analytics?.logEvent(name: name, parameters: parameters);
    }
  }

  static Future<void> recordError(Object error, StackTrace stack, {bool fatal = false}) async {
    if (_crashlyticsEnabled) {
      await FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
    }
  }
}