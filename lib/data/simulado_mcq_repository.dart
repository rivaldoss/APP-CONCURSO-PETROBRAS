import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/question.dart';

class SimuladoArea {
  final String key;
  final String label;

  const SimuladoArea(this.key, this.label);
}

class SimuladoAreas {
  static const operacao = SimuladoArea('operacao', 'Operação');
  static const manutEletrica = SimuladoArea('manutencao_eletrica', 'Manutenção • Elétrica');
  static const manutMecanica = SimuladoArea('manutencao_mecanica', 'Manutenção • Mecânica');
  static const manutInstr = SimuladoArea('manutencao_instrumentacao', 'Manutenção • Instrumentação');
  static const manutCaldeiraria = SimuladoArea('manutencao_caldeiraria', 'Manutenção • Caldeiraria');
  static const segTrabalho = SimuladoArea('seguranca_trabalho', 'Segurança do Trabalho');
  static const logistica = SimuladoArea('logistica_transporte', 'Logística de Transporte');

  static const all = <SimuladoArea>[
    operacao,
    manutEletrica,
    manutMecanica,
    manutInstr,
    manutCaldeiraria,
    segTrabalho,
    logistica,
  ];
}

class SimuladoMcqRepository {
  static const String assetPath = 'assets/questions/simulado_mcq.json';

  List<_Mcq>? _cache;

  Future<List<_Mcq>> _loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const <_Mcq>[];
    final list = decoded
        .whereType<Map<String, dynamic>>()
        .map(_Mcq.fromJson)
        .whereType<_Mcq>()
        .toList(growable: false);
    _cache = list;
    return list;
  }

  Future<List<Question>> loadPortuguese() async {
    final all = await _loadAll();
    return all
        .where((q) => q.materia == 'Português')
        .map((q) => q.toQuestion(subjectId: 'pt'))
        .toList(growable: false);
  }

  Future<List<Question>> loadMath() async {
    final all = await _loadAll();
    return all
        .where((q) => q.materia == 'Matemática/RLM')
        .map((q) => q.toQuestion(subjectId: 'mat'))
        .toList(growable: false);
  }

  Future<List<Question>> loadSpecific(String areaKey) async {
    final all = await _loadAll();
    return all
        .where((q) => q.materia == 'Específicas' && q.area == areaKey)
        .map((q) => q.toQuestion(subjectId: 'tec'))
        .toList(growable: false);
  }
}

class _Mcq {
  final String id;
  final String materia;
  final String area;
  final String enunciado;
  final List<String> options;
  final int correctIndex;
  final String explicacao;
  final String dificuldade;

  const _Mcq({
    required this.id,
    required this.materia,
    required this.area,
    required this.enunciado,
    required this.options,
    required this.correctIndex,
    required this.explicacao,
    required this.dificuldade,
  });

  static _Mcq? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final materia = json['materia'];
    final area = json['area'];
    final enunciado = json['enunciado'];
    final options = json['options'];
    final correctIndex = json['correctIndex'];
    final explicacao = json['explicacao'];
    final dificuldade = json['dificuldade'];

    if (id is! String ||
        materia is! String ||
        area is! String ||
        enunciado is! String ||
        options is! List ||
        correctIndex is! num ||
        explicacao is! String ||
        dificuldade is! String) {
      return null;
    }

    final opt = options.whereType<String>().toList(growable: false);
    final idx = correctIndex.toInt();
    if (opt.length != 5) return null;
    if (idx < 0 || idx >= opt.length) return null;

    return _Mcq(
      id: id,
      materia: materia,
      area: area,
      enunciado: enunciado,
      options: opt,
      correctIndex: idx,
      explicacao: explicacao,
      dificuldade: dificuldade,
    );
  }

  Question toQuestion({required String subjectId}) {
    return Question(
      id: id,
      subjectId: subjectId,
      statement: enunciado,
      options: options,
      correctIndex: correctIndex,
      quickExplanation: explicacao,
    );
  }
}

