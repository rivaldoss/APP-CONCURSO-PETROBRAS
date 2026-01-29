import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import 'firebase_bootstrap.dart';

class UserService {
  Stream<UserProfile?> watchMe() {
    if (!FirebaseBootstrap.initialized) return Stream.value(null);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return Stream.value(null);

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snap) {
        final data = snap.data() ?? <String, dynamic>{};
        final name = (data['displayName'] as String?)?.trim();
        final score = (data['score'] as num?)?.toInt() ?? 0;
        final cargo = (data['cargoPretendido'] as String?)?.trim();
        return UserProfile(
          uid: user.uid,
          displayName: (name == null || name.isEmpty) ? 'Usuário' : name,
          score: score,
          cargoPretendido: cargo ?? '',
        );
      });
    } catch (_) {
      return Stream.value(null);
    }
  }

  Future<bool> updateDisplayName(String displayName) async {
    final next = displayName.trim();
    if (next.isEmpty) return false;
    if (next.length > 24) return false;
    if (!FirebaseBootstrap.initialized) return false;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await ref.set({
        'displayName': next,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCargoPretendido(String cargoPretendido) async {
    final next = cargoPretendido.trim();
    if (next.isEmpty) return false;
    if (next.length > 40) return false;
    if (!FirebaseBootstrap.initialized) return false;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await ref.set({
        'cargoPretendido': next,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (_) {
      return false;
    }
  }
}
