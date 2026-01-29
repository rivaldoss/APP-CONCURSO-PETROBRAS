import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/question.dart';

class SimuladoController extends ChangeNotifier {
  final List<Question> questions;
  final Duration duration;

  SimuladoController({
    required this.questions,
    this.duration = const Duration(minutes: 60),
  }) : _remaining = duration;

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

  bool _finished = false;
  bool get finished => _finished;

  late Duration _remaining;
  Duration get remaining => _remaining;

  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_finished) return;
      final next = _remaining - const Duration(seconds: 1);
      _remaining = next.isNegative ? Duration.zero : next;
      if (_remaining == Duration.zero) {
        finish();
        return;
      }
      notifyListeners();
    });
  }

  double get progress {
    if (questions.isEmpty) return 0;
    final currentStep = _answered ? (_index + 1) : _index;
    return (currentStep / questions.length).clamp(0, 1);
  }

  void selectOption(int optionIndex) {
    if (_finished || _answered) return;
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

  bool canGoNext() => !_finished && _answered && _index < questions.length - 1;

  void next() {
    if (!canGoNext()) return;
    _index += 1;
    _answered = false;
    _selectedIndex = null;
    notifyListeners();
  }

  void finish() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    notifyListeners();
  }

  void restart() {
    _timer?.cancel();
    _index = 0;
    _correct = 0;
    _wrong = 0;
    _points = 0;
    _answered = false;
    _selectedIndex = null;
    _finished = false;
    _remaining = duration;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
