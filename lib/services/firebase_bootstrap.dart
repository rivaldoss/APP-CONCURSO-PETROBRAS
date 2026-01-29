import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  static bool _initialized = false;
  static bool get initialized => _initialized;

  static Future<void> tryInitialize() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (e) {
      // Sem google-services.json, isso pode falhar (ok no começo).
      if (kDebugMode) {
        // ignore: avoid_print
        print('Firebase não inicializado (ok no MVP): $e');
      }
      _initialized = false;
    }
  }
}

