import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_bootstrap.dart';

class ScoreService {
  static const int pointsPerCorrect = 1;
  static const int pointsPerWrong = -1;

  Future<void> addPoints({required int points}) async {
    if (!FirebaseBootstrap.initialized) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await ref.set({
        // Novo campo (ranking competitivo por pontuação líquida)
        'totalScore': FieldValue.increment(points),
        // Compatibilidade com versões anteriores do app (caso exista)
        'score': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // MVP: falha silenciosa.
    }
  }
}
