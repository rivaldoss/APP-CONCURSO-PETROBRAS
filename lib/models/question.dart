class Question {
  final String id;
  final String subjectId;
  final String statement;
  final List<String> options;
  final int correctIndex;
  final String quickExplanation;

  const Question({
    required this.id,
    required this.subjectId,
    required this.statement,
    required this.options,
    required this.correctIndex,
    required this.quickExplanation,
  });
}
