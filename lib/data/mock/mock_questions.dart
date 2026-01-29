import '../../models/question.dart';

class MockQuestions {
  static const portuguese = <Question>[
    Question(
      id: 'pt-q1',
      subjectId: 'pt',
      statement:
          'Em “A empresa divulgou o resultado, mas não detalhou os números.”, a conjunção “mas” indica:',
      options: ['Causa', 'Conclusão', 'Oposição/contraste', 'Explicação'],
      correctIndex: 2,
      quickExplanation:
          '“Mas” é conjunção coordenativa adversativa: introduz contraste/oposição em relação à ideia anterior.',
    ),
  ];

  static const math = <Question>[
    Question(
      id: 'mat-q1',
      subjectId: 'mat',
      statement: 'Se um produto custa R\$ 80 e recebe aumento de 25%, passa a custar:',
      options: ['R\$ 90', 'R\$ 95', 'R\$ 100', 'R\$ 105'],
      correctIndex: 2,
      quickExplanation: '25% de 80 é 20. Novo preço: 80 + 20 = 100.',
    ),
  ];

  // Mock Cebraspe (Certo/Errado) para SMS (5 questões).
  static const smsCebraspe = <Question>[
    Question(
      id: 'sms-q1',
      subjectId: 'sms',
      statement:
          'NR-06 trata de Equipamentos de Proteção Individual (EPI) e obriga o empregador a fornecer EPI adequado ao risco.',
      options: ['Certo', 'Errado'],
      correctIndex: 0,
      quickExplanation: 'A NR-06 estabelece regras para fornecimento, uso e responsabilidade sobre EPI.',
    ),
    Question(
      id: 'sms-q2',
      subjectId: 'sms',
      statement:
          'Na NR-13, caldeiras e vasos de pressão não exigem inspeção periódica quando operam abaixo da pressão máxima de trabalho.',
      options: ['Certo', 'Errado'],
      correctIndex: 1,
      quickExplanation:
          'A NR-13 prevê requisitos de integridade e inspeções; não existe essa “dispensa” genérica.',
    ),
    Question(
      id: 'sms-q3',
      subjectId: 'sms',
      statement:
          'Em incêndios, a classe de fogo “B” envolve líquidos inflamáveis; para esses casos, extintor de água é o mais indicado.',
      options: ['Certo', 'Errado'],
      correctIndex: 1,
      quickExplanation:
          'Água pode espalhar líquidos inflamáveis. Classe B costuma usar pó químico/espuma/CO₂ conforme cenário.',
    ),
    Question(
      id: 'sms-q4',
      subjectId: 'sms',
      statement:
          'A NR-10 trata de segurança em instalações e serviços em eletricidade, incluindo medidas de controle e procedimentos.',
      options: ['Certo', 'Errado'],
      correctIndex: 0,
      quickExplanation: 'A NR-10 define requisitos e condições mínimas para trabalhos com eletricidade.',
    ),
    Question(
      id: 'sms-q5',
      subjectId: 'sms',
      statement:
          'A NR-35 estabelece requisitos para trabalho em altura, incluindo treinamento e planejamento para prevenção de quedas.',
      options: ['Certo', 'Errado'],
      correctIndex: 0,
      quickExplanation: 'A NR-35 foca em planejamento, organização e execução segura do trabalho em altura.',
    ),
  ];

  static List<Question> bySubjectId(String subjectId) {
    return switch (subjectId) {
      'pt' => portuguese,
      'mat' => math,
      'sms' => smsCebraspe,
      _ => const <Question>[],
    };
  }
}
