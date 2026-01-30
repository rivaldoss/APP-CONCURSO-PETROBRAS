import 'dart:convert';
import 'dart:io';

/// Gera `assets/questions/simulado_mcq.json` com questões de múltipla escolha (A–E)
/// para o Simulado 60:
/// - 10 Português
/// - 10 Matemática/RLM
/// - 40 Específicas (conforme área)
///
/// Como usar (PowerShell na raiz do projeto):
/// `.\flutter\bin\flutter.bat pub run tool/generate_simulado_mcq_json.dart`
Future<void> main() async {
  final out = File('assets/questions/simulado_mcq.json');
  await out.parent.create(recursive: true);

  final questions = <Map<String, dynamic>>[];

  // -------------------------
  // Português (10)
  // -------------------------
  for (var i = 1; i <= 10; i++) {
    questions.add(_pt(i));
  }

  // -------------------------
  // Matemática/RLM (10)
  // -------------------------
  for (var i = 1; i <= 10; i++) {
    questions.add(_mat(i));
  }

  // -------------------------
  // Áreas (40 cada)
  // -------------------------
  for (final area in _Area.values) {
    for (var i = 1; i <= 40; i++) {
      questions.add(_tech(area, i));
    }
  }

  const encoder = JsonEncoder.withIndent('  ');
  await out.writeAsString(encoder.convert(questions), flush: true);
  // ignore: avoid_print
  print('OK: gerado ${questions.length} questões em ${out.path}');
}

Map<String, dynamic> _base({
  required String id,
  required String materia,
  required String area,
  required String enunciado,
  required List<String> options,
  required int correctIndex,
  required String explicacao,
  required String dificuldade,
}) {
  return <String, dynamic>{
    'id': id,
    'materia': materia, // "Português" | "Matemática/RLM" | "Específicas"
    'area': area, // "geral" | operacao | manutencao_eletrica | ...
    'enunciado': enunciado,
    'options': options, // A..E
    'correctIndex': correctIndex, // 0..4
    'explicacao': explicacao,
    'dificuldade': dificuldade, // facil|media|dificil
  };
}

Map<String, dynamic> _pt(int i) {
  final id = 'pt-mcq-${i.toString().padLeft(3, '0')}';
  final variants = <Map<String, dynamic>>[
    _base(
      id: id,
      materia: 'Português',
      area: 'geral',
      enunciado:
          'Assinale a alternativa em que a reescrita mantém o sentido e a correção em um relatório de SMS.',
      options: const [
        '“A equipe mitigou o risco, porém atrasou o bloqueio” → “A equipe mitigou o risco, contudo atrasou o bloqueio”.',
        '“Fazem dois anos de operação” → “Fazem-se dois anos de operação”.',
        '“Houve falhas no vaso” → “Houveram falhas no vaso”.',
        '“Chegamos à conclusão” → “Chegamos a conclusão”.',
        '“Obedeceram à NR-10” → “Obedeceram a NR-10”.',
      ],
      correctIndex: 0,
      explicacao: '“Porém/contudo” são adversativos e preservam a relação de contraste; as demais têm erro.',
      dificuldade: 'media',
    ),
    _base(
      id: id,
      materia: 'Português',
      area: 'geral',
      enunciado:
          'Em norma-padrão, assinale a alternativa correta quanto à crase em contexto técnico.',
      options: const [
        '“Entregou a equipe à OS” está correto.',
        '“O operador obedeceu à norma interna” está correto.',
        '“Retornou a à sala de controle” está correto.',
        '“Foi a uma à reunião” está correto.',
        '“Refere-se às válvulas de alívio” está correto.',
      ],
      correctIndex: 1,
      explicacao: '“Obedecer a” + artigo “a” → “à”. As demais têm ausência/excesso de crase.',
      dificuldade: 'media',
    ),
  ];
  return variants[i.isEven ? 0 : 1];
}

Map<String, dynamic> _mat(int i) {
  final id = 'mat-mcq-${i.toString().padLeft(3, '0')}';
  final variants = <Map<String, dynamic>>[
    _base(
      id: id,
      materia: 'Matemática/RLM',
      area: 'geral',
      enunciado:
          'Um sistema possui 6 válvulas, das quais 2 são críticas. Ao escolher uma válvula ao acaso, qual a probabilidade de escolher uma crítica?',
      options: const ['1/6', '1/3', '1/2', '2/3', '5/6'],
      correctIndex: 1,
      explicacao: 'Probabilidade = 2/6 = 1/3.',
      dificuldade: 'facil',
    ),
    _base(
      id: id,
      materia: 'Matemática/RLM',
      area: 'geral',
      enunciado:
          'Quantas maneiras há de escolher 2 instrumentos distintos dentre 7, sem considerar a ordem?',
      options: const ['14', '21', '28', '35', '42'],
      correctIndex: 1,
      explicacao: 'Combinação: C(7,2)=21.',
      dificuldade: 'media',
    ),
  ];
  return variants[i.isEven ? 0 : 1];
}

enum _Area {
  operacao,
  manutencao_eletrica,
  manutencao_mecanica,
  manutencao_instrumentacao,
  manutencao_caldeiraria,
  seguranca_trabalho,
  logistica_transporte,
}

String _areaKey(_Area a) => switch (a) {
      _Area.operacao => 'operacao',
      _Area.manutencao_eletrica => 'manutencao_eletrica',
      _Area.manutencao_mecanica => 'manutencao_mecanica',
      _Area.manutencao_instrumentacao => 'manutencao_instrumentacao',
      _Area.manutencao_caldeiraria => 'manutencao_caldeiraria',
      _Area.seguranca_trabalho => 'seguranca_trabalho',
      _Area.logistica_transporte => 'logistica_transporte',
    };

Map<String, dynamic> _tech(_Area area, int i) {
  final id = '${_areaKey(area)}-mcq-${i.toString().padLeft(3, '0')}';
  final a = _areaKey(area);

  // Templates curtos para gerar volume sem depender de arquivo .dart no app.
  // O objetivo aqui é montar um banco inicial para o Simulado 60.
  switch (area) {
    case _Area.operacao:
      return _base(
        id: id,
        materia: 'Específicas',
        area: a,
        enunciado:
            'Em operação de separador, qual ação é mais adequada ao observar tendência de aumento de nível com alarme alto persistente?',
        options: const [
          'Ignorar o alarme, pois pode ser “ruído” do sensor.',
          'Verificar válvula de saída/linha e confirmar leitura com indicador redundante, seguindo procedimento.',
          'Aumentar pressão do vaso para reduzir nível.',
          'Fechar PSV para evitar perda de produto.',
          'Desabilitar a malha de controle para “estabilizar”.',
        ],
        correctIndex: 1,
        explicacao: 'Boa prática: confirmar medição e atuar conforme procedimento, verificando restrições/atuadores.',
        dificuldade: 'media',
      );
    case _Area.manutencao_eletrica:
      return _base(
        id: id,
        materia: 'Específicas',
        area: a,
        enunciado:
            'Em manutenção elétrica, qual sequência está mais alinhada com a NR-10 para intervenção em painel?',
        options: const [
          'Abrir painel e iniciar teste para ganhar tempo.',
          'Desenergizar, bloquear/etiquetar, verificar ausência de tensão e sinalizar área.',
          'Somente desligar o disjuntor e iniciar trabalho.',
          'Usar luva isolante e dispensar documentação.',
          'Trabalhar energizado se a tensão for “baixa”.',
        ],
        correctIndex: 1,
        explicacao: 'NR-10: desenergização segura + impedimento de reenergização + verificação e sinalização.',
        dificuldade: 'media',
      );
    case _Area.manutencao_mecanica:
      return _base(
        id: id,
        materia: 'Específicas',
        area: a,
        enunciado:
            'Em manutenção mecânica de bomba centrífuga, qual sintoma está mais associado à cavitação?',
        options: const [
          'Aumento de eficiência e redução de ruído.',
          'Ruído tipo “brita”, vibração e queda de desempenho.',
          'Temperatura do motor sempre mais baixa.',
          'Aumento de NPSH disponível por obstrução na sucção.',
          'Pressão de sucção sempre aumenta.',
        ],
        correctIndex: 1,
        explicacao: 'Cavitação: formação/colapso de bolhas → ruído, vibração, erosão e perda de desempenho.',
        dificuldade: 'media',
      );
    case _Area.manutencao_instrumentacao:
      return _base(
        id: id,
        materia: 'Específicas',
        area: a,
        enunciado:
            'Em instrumentação, qual afirmação sobre sinal 4–20 mA é correta?',
        options: const [
          '0 mA representa o zero da faixa, sempre.',
          '4 mA geralmente representa o LRV e permite detecção de falha abaixo desse valor.',
          '20 mA representa falha do transmissor.',
          'O sinal 4–20 mA não pode ser calibrado.',
          '4–20 mA só funciona em loop aberto.',
        ],
        correctIndex: 1,
        explicacao: 'Padrão: 4 mA = LRV, 20 mA = URV; faixa viva ajuda a detectar falhas.',
        dificuldade: 'facil',
      );
    case _Area.manutencao_caldeiraria:
      return _base(
        id: id,
        materia: 'Específicas',
        area: a,
        enunciado:
            'Em caldeiraria e integridade, qual prática é mais adequada ao identificar corrosão em trecho de tubulação de processo?',
        options: const [
          'Aumentar a pressão de operação para “selar” a corrosão.',
          'Registrar, avaliar espessura/remanescente e encaminhar para plano de reparo conforme integridade/NR-13 quando aplicável.',
          'Pintar externamente e liberar sem inspeção.',
          'Ignorar se não houver vazamento visível.',
          'Substituir por material inferior para reduzir custo.',
        ],
        correctIndex: 1,
        explicacao: 'Gestão de integridade exige registro, avaliação e reparo planejado com critérios técnicos.',
        dificuldade: 'media',
      );
    case _Area.seguranca_trabalho:
      return _base(
        id: id,
        materia: 'Específicas',
        area: a,
        enunciado:
            'Em um trabalho em altura, qual item é essencial antes da execução (NR-35)?',
        options: const [
          'Apenas capacete e luvas.',
          'Análise de risco, sistema de ancoragem adequado e treinamento do trabalhador.',
          'Somente “experiência” do trabalhador.',
          'Desabilitar bloqueios para acelerar.',
          'Dispensar inspeção do cinturão.',
        ],
        correctIndex: 1,
        explicacao: 'NR-35: planejamento/AR, sistema de proteção contra quedas e capacitação.',
        dificuldade: 'facil',
      );
    case _Area.logistica_transporte:
      return _base(
        id: id,
        materia: 'Específicas',
        area: a,
        enunciado:
            'Na logística de transporte, qual ação reduz risco operacional no carregamento/descarga de materiais críticos em área industrial?',
        options: const [
          'Aumentar velocidade de manobra para reduzir tempo de permanência.',
          'Planejar rota, sinalizar, isolar área e cumprir checklists de amarração/inspeção do veículo.',
          'Dispensar inspeção, pois o motorista é terceirizado.',
          'Carregar acima do limite para “otimizar”.',
          'Eliminar comunicação com a área para evitar “interferência”.',
        ],
        correctIndex: 1,
        explicacao: 'Planejamento, isolamento/sinalização e checklist reduzem incidentes no transporte interno.',
        dificuldade: 'media',
      );
  }
}

