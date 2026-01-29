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
  ];
}
