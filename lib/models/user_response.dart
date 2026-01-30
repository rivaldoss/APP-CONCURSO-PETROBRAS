/// Resposta do usuário para uma questão.
///
/// - `correct`: marcou alternativa correta (+1)
/// - `wrong`: marcou alternativa errada (-1)
/// - `skipped`: pulou / "não sei" (0)
enum UserResponseType { correct, wrong, skipped }

class UserResponse {
  final String questionId;
  final UserResponseType type;

  const UserResponse({
    required this.questionId,
    required this.type,
  });
}

