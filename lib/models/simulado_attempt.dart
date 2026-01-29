class SimuladoAttempt {
  final String id;
  final String mode; // "subject" | "mixed" | "unknown"
  final String? subjectId;
  final String title;
  final int total;
  final int correct;
  final int bonus;
  final int points;
  final int remainingSeconds;
  final DateTime? createdAt;

  const SimuladoAttempt({
    required this.id,
    required this.mode,
    required this.subjectId,
    required this.title,
    required this.total,
    required this.correct,
    required this.bonus,
    required this.points,
    required this.remainingSeconds,
    required this.createdAt,
  });
}
