import '../models/user_response.dart';

/// Pontuação bruta Cebraspe:
/// - correta: +1
/// - errada: -1
/// - pulada: 0
int calculateRawScore(List<UserResponse> responses) {
  var score = 0;
  for (final r in responses) {
    score += switch (r.type) {
      UserResponseType.correct => 1,
      UserResponseType.wrong => -1,
      UserResponseType.skipped => 0,
    };
  }
  return score;
}

/// Pontuação líquida (não negativa) para feedback/ranking.
int calculateLiquidScore(List<UserResponse> responses) {
  final raw = calculateRawScore(responses);
  return raw < 0 ? 0 : raw;
}

