import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  /// Modo offline do MVP:
  /// - Não inicializa Firebase
  /// - Evita chamadas ao Firestore/Auth para você testar o app sem Billing
  static const bool offlineMode = true;

  static bool _initialized = false;
  static bool get initialized => _initialized;

  static Future<void> tryInitialize() async {
    if (offlineMode) {
      _initialized = false;
      return;
    }
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

