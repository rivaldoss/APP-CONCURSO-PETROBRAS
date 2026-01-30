import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/question.dart';

/// Repositório que carrega questões de um asset JSON.
///
/// Caminho do asset esperado:
/// - `assets/questions/questions.json`
class QuestionJsonRepository {
  static const String assetPath = 'assets/questions/questions.json';

  List<_JsonQuestion>? _cache;

  Future<List<_JsonQuestion>> _loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const <_JsonQuestion>[];
    final list = decoded
        .whereType<Map<String, dynamic>>()
        .map(_JsonQuestion.fromJson)
        .whereType<_JsonQuestion>()
        .toList(growable: false);
    _cache = list;
    return list;
  }

  Future<List<Question>> loadForSubjectId(String subjectId) async {
    final all = await _loadAll();
    final filtered = all.where((q) => _subjectIdForMateria(q.materia) == subjectId);
    return filtered.map((q) => q.toQuestion()).toList(growable: false);
  }

  Future<List<Question>> loadMixed() async {
    final all = await _loadAll();
    return all.map((q) => q.toQuestion()).toList(growable: false);
  }

  /// Seleciona N questões aleatórias (sem repetição).
  /// Se houver menos que N, retorna todas.
  List<Question> pickRandom(List<Question> input, int n, {Random? random}) {
    if (input.isEmpty) return const <Question>[];
    if (input.length <= n) return input.toList(growable: false);
    final list = input.toList(growable: false);
    list.shuffle(random ?? Random());
    return list.take(n).toList(growable: false);
  }
}

String _subjectIdForMateria(String materia) {
  final m = materia.toLowerCase();
  if (m.contains('portugu')) return 'pt';
  if (m.contains('matem') || m.contains('rlm')) return 'mat';
  if (m.contains('sms')) return 'sms';
  return 'tec';
}

enum _Difficulty { facil, media, dificil }

class _JsonQuestion {
  final String id;
  final String materia;
  final String bloco;
  final String enunciado;
  final bool respostaCorreta;
  final String explicacao;
  final _Difficulty dificuldade;

  const _JsonQuestion({
    required this.id,
    required this.materia,
    required this.bloco,
    required this.enunciado,
    required this.respostaCorreta,
    required this.explicacao,
    required this.dificuldade,
  });

  static _JsonQuestion? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final materia = json['materia'];
    final bloco = json['bloco'];
    final enunciado = json['enunciado'];
    final respostaCorreta = json['respostaCorreta'];
    final explicacao = json['explicacao'];
    final dificuldadeRaw = (json['dificuldade'] as String?)?.toLowerCase().trim();

    if (id is! String ||
        materia is! String ||
        bloco is! String ||
        enunciado is! String ||
        respostaCorreta is! bool ||
        explicacao is! String) {
      return null;
    }

    final dificuldade = switch (dificuldadeRaw) {
      'facil' => _Difficulty.facil,
      'média' || 'media' => _Difficulty.media,
      'difícil' || 'dificil' => _Difficulty.dificil,
      _ => _Difficulty.media,
    };

    return _JsonQuestion(
      id: id,
      materia: materia,
      bloco: bloco,
      enunciado: enunciado,
      respostaCorreta: respostaCorreta,
      explicacao: explicacao,
      dificuldade: dificuldade,
    );
  }

  Question toQuestion() {
    return Question(
      id: id,
      subjectId: _subjectIdForMateria(materia),
      statement: enunciado,
      options: const ['Certo', 'Errado'],
      correctIndex: respostaCorreta ? 0 : 1,
      quickExplanation: explicacao,
    );
  }
}

