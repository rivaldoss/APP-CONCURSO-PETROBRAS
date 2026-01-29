import 'package:flutter/foundation.dart';

import '../models/question.dart';

class QuizController extends ChangeNotifier {
  final List<Question> questions;

  QuizController({required this.questions});

  int _index = 0;
  int get index => _index;
  Question get current => questions[_index];

  int _correct = 0;
  int get correct => _correct;

  int _wrong = 0;
  int get wrong => _wrong;

  int _points = 0;
  int get points => _points;

  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;

  bool _answered = false;
  bool get answered => _answered;

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
      _points += 10;
    } else {
      _wrong += 1;
      _points -= 5;
    }

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
    _points = 0;
    _answered = false;
    _selectedIndex = null;
    notifyListeners();
  }
}
