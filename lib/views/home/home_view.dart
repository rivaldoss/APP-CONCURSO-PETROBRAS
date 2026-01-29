import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../data/mock/mock_questions.dart';
import '../../models/subject.dart';
import '../profile/profile_screen.dart';
import '../quiz/quiz_screen.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trilhas • Nível Técnico'),
        actions: [
          IconButton(
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: app.toggleThemeMode,
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: app.subjects.length,
        itemBuilder: (context, index) {
          final s = app.subjects[index];
          final progress = app.progressFor(s.id);
          final questions = MockQuestions.bySubjectId(s.id);

          final isYellow = index.isOdd;
          final bg = isYellow ? cs.secondaryContainer : cs.primaryContainer;
          final fg = isYellow ? cs.onSecondaryContainer : cs.onPrimaryContainer;

          return _SubjectCard(
            subject: s,
            progress: progress,
            background: bg,
            foreground: fg,
            onStart: questions.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          title: s.title,
                          subjectId: s.id,
                          questions: questions,
                        ),
                      ),
                    );
                  },
          );
        },
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final double progress;
  final Color background;
  final Color foreground;
  final VoidCallback? onStart;

  const _SubjectCard({
    required this.subject,
    required this.progress,
    required this.background,
    required this.foreground,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onStart,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  subject.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900, color: foreground),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${subject.topics.length} tópicos',
                style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: subject.topics.take(3).map((t) {
                  final isHigh = t.priority == TopicPriority.high;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isHigh
                          ? cs.errorContainer.withOpacity(0.5)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isHigh ? '${t.title} • Alta' : t.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isHigh ? cs.onErrorContainer : cs.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(value: progress),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$pct%', style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onStart,
                  child: const Text('Começar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
