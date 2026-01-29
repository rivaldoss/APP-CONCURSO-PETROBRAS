import 'package:flutter/material.dart';

import '../constants/subjects.dart';
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
}

