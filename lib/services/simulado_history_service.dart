import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/simulado_attempt.dart';
import 'firebase_bootstrap.dart';

class SimuladoHistoryService {
  Stream<List<SimuladoAttempt>> watchLast10() {
    if (!FirebaseBootstrap.initialized) return const Stream.empty();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return const Stream.empty();

      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('simulados')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots()
          .map((snap) {
        return snap.docs.map((d) {
          final data = d.data();
          final mode = (data['mode'] as String?) ?? 'unknown';
          final subjectId = data['subjectId'] as String?;
          final title = (data['title'] as String?) ?? 'Simulado';
          final total = (data['total'] as num?)?.toInt() ?? 0;
          final correct = (data['correct'] as num?)?.toInt() ?? 0;
          final bonus = (data['bonus'] as num?)?.toInt() ?? 0;
          final points = (data['points'] as num?)?.toInt() ?? 0;
          final remainingSeconds = (data['remainingSeconds'] as num?)?.toInt() ?? 0;

          final ts = data['createdAt'];
          DateTime? createdAt;
          if (ts is Timestamp) createdAt = ts.toDate();

          return SimuladoAttempt(
            id: d.id,
            mode: mode,
            subjectId: subjectId,
            title: title,
            total: total,
            correct: correct,
            bonus: bonus,
            points: points,
            remainingSeconds: remainingSeconds,
            createdAt: createdAt,
          );
        }).toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<void> addAttempt({
    required String mode,
    required String? subjectId,
    required String title,
    required int total,
    required int correct,
    required int bonus,
    required int points,
    required int remainingSeconds,
  }) async {
    if (!FirebaseBootstrap.initialized) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('simulados')
          .add({
        'mode': mode,
        'subjectId': subjectId,
        'title': title,
        'total': total,
        'correct': correct,
        'bonus': bonus,
        'points': points,
        'remainingSeconds': remainingSeconds,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> deleteAttempt(String attemptId) async {
    if (!FirebaseBootstrap.initialized) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('simulados')
          .doc(attemptId)
          .delete();
    } catch (_) {}
  }

  Future<void> restoreAttempt(SimuladoAttempt attempt) async {
    if (!FirebaseBootstrap.initialized) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final createdAt = attempt.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(attempt.createdAt!);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('simulados')
          .doc(attempt.id)
          .set({
        'mode': attempt.mode,
        'subjectId': attempt.subjectId,
        'title': attempt.title,
        'total': attempt.total,
        'correct': attempt.correct,
        'bonus': attempt.bonus,
        'points': attempt.points,
        'remainingSeconds': attempt.remainingSeconds,
        'createdAt': createdAt,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> clearAll() async {
    if (!FirebaseBootstrap.initialized) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('simulados');

      for (var i = 0; i < 20; i++) {
        final snap = await col.limit(200).get();
        if (snap.docs.isEmpty) break;

        final batch = FirebaseFirestore.instance.batch();
        for (final d in snap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }
    } catch (_) {}
  }
}
