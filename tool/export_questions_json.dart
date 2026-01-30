import 'dart:convert';
import 'dart:io';

import '../lib/data/question_bank.dart';

/// Exporta o banco em Dart (`lib/data/question_bank.dart`) para JSON em:
/// - `assets/questions/questions.json`
///
/// Execute (PowerShell, na raiz do projeto):
/// `.\flutter\bin\flutter.bat pub get`
/// `.\flutter\bin\flutter.bat pub run tool/export_questions_json.dart`
Future<void> main() async {
  final out = File('assets/questions/questions.json');
  await out.parent.create(recursive: true);

  final jsonList = questionBank.map((q) {
    return <String, dynamic>{
      'id': q.id,
      'materia': q.materia,
      'bloco': q.bloco,
      'enunciado': q.enunciado,
      'respostaCorreta': q.respostaCorreta,
      'explicacao': q.explicacao,
      'dificuldade': switch (q.dificuldade) {
        Difficulty.facil => 'facil',
        Difficulty.media => 'media',
        Difficulty.dificil => 'dificil',
      },
    };
  }).toList();

  const encoder = JsonEncoder.withIndent('  ');
  await out.writeAsString(encoder.convert(jsonList), flush: true);
  // ignore: avoid_print
  print('OK: gerado ${jsonList.length} questões em ${out.path}');
}

