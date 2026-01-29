import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../data/mock/mock_questions.dart';
import '../../models/question.dart';
import '../profile/profile_screen.dart';
import 'simulado_screen.dart';

class SimuladoSetupScreen extends StatelessWidget {
  const SimuladoSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulado'),
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
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          const _Header(),
          ...app.subjects.map((s) {
            final questions = MockQuestions.bySubjectId(s.id);
            return _SimuladoCard(
              title: s.title,
              subtitle: '${questions.length} questões • 60:00',
              enabled: questions.isNotEmpty,
              onStart: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SimuladoScreen(
                      title: 'Simulado - ${s.title}',
                      questions: questions,
                      mode: 'subject',
                      subjectId: s.id,
                    ),
                  ),
                );
              },
            );
          }),
          Builder(
            builder: (context) {
              final List<Question> mixed = [
                ...MockQuestions.portuguese,
                ...MockQuestions.math,
                ...MockQuestions.smsCebraspe,
              ];
              return _SimuladoCard(
                title: 'Misto',
                subtitle: '${mixed.length} questões • 60:00',
                enabled: mixed.isNotEmpty,
                onStart: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SimuladoScreen(
                        title: 'Simulado - Misto',
                        questions: mixed,
                        mode: 'mixed',
                        subjectId: null,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.timer, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('60 minutos', style: TextStyle(fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('Cebraspe: +10 certo / -5 errado.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimuladoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onStart;

  const _SimuladoCard({
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(subtitle),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: enabled ? onStart : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
