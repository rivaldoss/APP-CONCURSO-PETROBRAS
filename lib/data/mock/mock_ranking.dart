import '../../models/ranking_entry.dart';

class MockRanking {
  static const top10 = <RankingEntry>[
    RankingEntry(userId: 'u1', displayName: 'Ana', score: 1280),
    RankingEntry(userId: 'u2', displayName: 'Bruno', score: 1210),
    RankingEntry(userId: 'u3', displayName: 'Carla', score: 1180),
    RankingEntry(userId: 'u4', displayName: 'Diego', score: 1110),
    RankingEntry(userId: 'u5', displayName: 'Evelyn', score: 990),
    RankingEntry(userId: 'u6', displayName: 'Felipe', score: 940),
    RankingEntry(userId: 'u7', displayName: 'Gabi', score: 910),
    RankingEntry(userId: 'u8', displayName: 'Henrique', score: 860),
    RankingEntry(userId: 'u9', displayName: 'Isabela', score: 830),
    RankingEntry(userId: 'u10', displayName: 'João', score: 800),
  ];
}
