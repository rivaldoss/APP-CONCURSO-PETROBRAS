import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_bootstrap.dart';

class ScoreService {
  static const int pointsPerCorrect = 10;
  static const int pointsPerWrong = -5;

  Future<void> addPoints({required int points}) async {
    if (!FirebaseBootstrap.initialized) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await ref.set({
        'score': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // MVP: falha silenciosa.
    }
  }
}
