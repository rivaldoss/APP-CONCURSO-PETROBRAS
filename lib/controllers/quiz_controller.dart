import 'package:flutter/foundation.dart';

import '../models/question.dart';
import '../models/user_response.dart';
import '../utils/scoring.dart';

class QuizController extends ChangeNotifier {
  final List<Question> questions;

  QuizController({required this.questions})
      : _responses = List<UserResponse?>.filled(questions.length, null, growable: false);

  int _index = 0;
  int get index => _index;
  Question get current => questions[_index];

  int _correct = 0;
  int get correct => _correct;

  int _wrong = 0;
  int get wrong => _wrong;

  int get skipped => _responses.where((r) => r?.type == UserResponseType.skipped).length;

  List<UserResponse> get responses => _responses.whereType<UserResponse>().toList(growable: false);

  int get rawPoints => calculateRawScore(responses);

  int get liquidPoints => calculateLiquidScore(responses);

  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;

  bool _answered = false;
  bool get answered => _answered;

  final List<UserResponse?> _responses;

  bool get isCorrect {
    if (!_answered || _selectedIndex == null) return false;
    return _selectedIndex == current.correctIndex;
  }

  double get progress {
    if (questions.isEmpty) return 0;
    final currentStep = _answered ? (_index + 1) : _index;
    return (currentStep / questions.length).clamp(0, 1);
  }

  void selectOption(int optionIndex) {
    if (_answered) return;
    _selectedIndex = optionIndex;
    _answered = true;

    if (optionIndex == current.correctIndex) {
      _correct += 1;
      _responses[_index] = UserResponse(questionId: current.id, type: UserResponseType.correct);
    } else {
      _wrong += 1;
      _responses[_index] = UserResponse(questionId: current.id, type: UserResponseType.wrong);
    }

    notifyListeners();
  }

  void skip() {
    if (_answered) return;
    _selectedIndex = null;
    _answered = true;
    _responses[_index] = UserResponse(questionId: current.id, type: UserResponseType.skipped);
    notifyListeners();
  }

  bool canGoNext() => _answered && _index < questions.length - 1;

  void next() {
    if (!canGoNext()) return;
    _index += 1;
    _answered = false;
    _selectedIndex = null;
    notifyListeners();
  }

  void restart() {
    _index = 0;
    _correct = 0;
    _wrong = 0;
    _answered = false;
    _selectedIndex = null;
    for (var i = 0; i < _responses.length; i++) {
      _responses[i] = null;
    }
    notifyListeners();
  }
}
