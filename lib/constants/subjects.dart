import '../models/subject.dart';

class SubjectsConstants {
  static const technical = <Subject>[
    Subject(
      id: 'pt',
      title: 'Língua Portuguesa',
      topics: [
        Topic(id: 'pt-interpretacao', title: 'Interpretação de texto'),
        Topic(id: 'pt-gramatica', title: 'Gramática essencial'),
        Topic(id: 'pt-redacao', title: 'Coesão e coerência'),
      ],
    ),
    Subject(
      id: 'mat',
      title: 'Matemática',
      topics: [
        Topic(id: 'mat-razao', title: 'Razões e proporções'),
        Topic(id: 'mat-porcentagem', title: 'Porcentagem'),
        Topic(id: 'mat-estatistica', title: 'Estatística básica'),
      ],
    ),
    Subject(
      id: 'sms',
      title: 'SMS (Segurança, Meio Ambiente e Saúde)',
      topics: [
        Topic(id: 'sms-nr06', title: 'NR-06: EPI', priority: TopicPriority.high),
        Topic(
          id: 'sms-nr13',
          title: 'NR-13: Caldeiras e Vasos de Pressão',
          priority: TopicPriority.high,
        ),
        Topic(
          id: 'sms-incendio',
          title: 'Prevenção e Combate a Incêndio',
          priority: TopicPriority.high,
        ),
        Topic(id: 'sms-nr10', title: 'NR-10'),
        Topic(id: 'sms-nr35', title: 'NR-35'),
        Topic(id: 'sms-primeiros-socorros', title: 'Primeiros Socorros'),
      ],
    ),
    Subject(
      id: 'tec',
      title: 'Conhecimentos Específicos (Técnico)',
      topics: [
        Topic(id: 'tec-termo', title: 'Termodinâmica básica', priority: TopicPriority.high),
        Topic(id: 'tec-fluidos', title: 'Mecânica dos fluidos', priority: TopicPriority.high),
        Topic(id: 'tec-instrumentacao', title: 'Instrumentação', priority: TopicPriority.high),
        Topic(id: 'tec-controle', title: 'Controle de processos', priority: TopicPriority.high),
        Topic(id: 'tec-balancos', title: 'Balanços de massa e energia'),
        Topic(id: 'tec-equipamentos', title: 'Equipamentos de processo (bombas/compressores)'),
      ],
    ),
  ];
}
