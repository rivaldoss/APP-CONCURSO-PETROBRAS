import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/subjects.dart';
import '../models/question.dart';
import '../models/subject.dart';

class AppController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  final List<Subject> subjects = SubjectsConstants.technical;

  // Progresso (0..1) por matéria.
  final Map<String, double> _progressBySubjectId = {
    'pt': 0.12,
    'mat': 0.08,
    'sms': 0.0,
    'tec': 0.0,
  };

  double progressFor(String subjectId) => (_progressBySubjectId[subjectId] ?? 0).clamp(0, 1);

  void setProgress(String subjectId, double value) {
    _progressBySubjectId[subjectId] = value.clamp(0, 1);
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = switch (_themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      _ => ThemeMode.dark,
    };
    notifyListeners();
  }

  // -------------------------
  // Sorteio sem repetição (sessão atual)
  // -------------------------
  final Map<String, Set<String>> _usedQuestionIdsByPoolKey = {};

  /// Retorna até [count] questões aleatórias sem repetir (na sessão atual) para a mesma [poolKey].
  ///
  /// - Se o banco da matéria tiver menos que [count], retorna todas.
  /// - Se as questões “acabarem” (já usadas), reinicia o ciclo daquela matéria.
  List<Question> pickNonRepeating({
    required String poolKey,
    required List<Question> pool,
    required int count,
  }) {
    if (pool.isEmpty) return const <Question>[];
    if (pool.length <= count) return pool.toList(growable: false);

    final used = _usedQuestionIdsByPoolKey.putIfAbsent(poolKey, () => <String>{});

    // Remove IDs que não existem mais no pool (caso o JSON mude).
    final poolIds = pool.map((q) => q.id).toSet();
    used.removeWhere((id) => !poolIds.contains(id));

    var available = pool.where((q) => !used.contains(q.id)).toList(growable: false);
    if (available.length < count) {
      // Reinicia o ciclo (agora pode repetir, mas só após esgotar).
      used.clear();
      available = pool.toList(growable: false);
    }

    available.shuffle(Random());
    final picked = available.take(count).toList(growable: false);
    used.addAll(picked.map((q) => q.id));
    return picked;
  }
}

