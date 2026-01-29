import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_bootstrap.dart';

class AuthService {
  Future<User?> trySignInAnonymously() async {
    if (!FirebaseBootstrap.initialized) return null;

    try {
      final auth = FirebaseAuth.instance;
      final current = auth.currentUser;
      if (current != null) {
        await _ensureUserDoc(current);
        return current;
      }

      final credential = await auth.signInAnonymously();
      final user = credential.user;
      if (user != null) {
        await _ensureUserDoc(user);
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureUserDoc(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final suffix = user.uid.substring(0, 4).toUpperCase();
    await ref.set({
      'displayName': 'Usuário $suffix',
      'cargoPretendido': '',
      'score': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

