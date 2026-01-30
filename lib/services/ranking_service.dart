import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/mock/mock_ranking.dart';
import '../models/ranking_entry.dart';
import 'firebase_bootstrap.dart';

class RankingService {
  Stream<List<RankingEntry>> watchTop10() {
    if (!FirebaseBootstrap.initialized) {
      return Stream.value(MockRanking.top10);
    }

    List<RankingEntry> mapSnap(QuerySnapshot<Map<String, dynamic>> snap) {
      final items = snap.docs.map((d) {
        final data = d.data();
        final name = (data['displayName'] as String?)?.trim();
        final score =
            (data['totalScore'] as num?)?.toInt() ?? (data['score'] as num?)?.toInt() ?? 0;
        return RankingEntry(
          userId: d.id,
          displayName: (name == null || name.isEmpty) ? 'Usuário' : name,
          score: score,
        );
      }).toList();

      return items.isEmpty ? MockRanking.top10 : items;
    }

    // Preferimos `totalScore`, mas fazemos fallback para `score` se ainda não existir.
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .orderBy('totalScore', descending: true)
          .limit(10)
          .snapshots()
          .map(mapSnap);
    } catch (_) {
      try {
        return FirebaseFirestore.instance
            .collection('users')
            .orderBy('score', descending: true)
            .limit(10)
            .snapshots()
            .map(mapSnap);
      } catch (_) {
        return Stream.value(MockRanking.top10);
      }
    }
  }

  Future<int?> fetchMyRank() async {
    if (!FirebaseBootstrap.initialized) return null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final myDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final myData = myDoc.data();
      if (myData == null) return null;

      final myScore =
          (myData['totalScore'] as num?)?.toInt() ?? (myData['score'] as num?)?.toInt() ?? 0;
      final agg = await FirebaseFirestore.instance
          .collection('users')
          .where('totalScore', isGreaterThan: myScore)
          .count()
          .get();

      final c = agg.count ?? 0;
      return c + 1;
    } catch (_) {
      return null;
    }
  }
}
