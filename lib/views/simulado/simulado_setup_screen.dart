import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../data/question_json_repository.dart';
import '../../data/simulado_mcq_repository.dart';
import '../../models/question.dart';
import '../profile/profile_screen.dart';
import 'simulado_screen.dart';

class SimuladoSetupScreen extends StatelessWidget {
  const SimuladoSetupScreen({super.key});

  static const int _questionsPerSimulado = 20;
  static const int _questionsPerSimulado60 = 60;

  Future<void> _startSimulado(
    BuildContext context, {
    required String title,
    required Future<List<Question>> Function() loadQuestions,
    required String mode,
    required String? subjectId,
  }) async {
    final repo = QuestionJsonRepository();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text('Carregando questões...')),
            ],
          ),
        ),
      ),
    );

    try {
      final raw = await loadQuestions();
      final app = context.read<AppController>();
      final key = mode == 'mixed' ? 'simulado:mixed' : 'simulado:${subjectId ?? 'unknown'}';
      final questions = app.pickNonRepeating(
        poolKey: key,
        pool: raw,
        count: _questionsPerSimulado,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop(); // fecha loading

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhuma questão encontrada no questions.json.')),
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SimuladoScreen(
            title: title,
            questions: questions,
            mode: mode,
            subjectId: subjectId,
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // fecha loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao carregar questions.json.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final repo = QuestionJsonRepository();
    final mcqRepo = SimuladoMcqRepository();

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
          _SimuladoCard(
            title: 'Simulado 60 (A–E)',
            subtitle: '10 Português + 10 Matemática + 40 Específicas (por área)',
            enabled: true,
            onStart: () async {
              final pickedArea = await showDialog<SimuladoArea?>(
                context: context,
                builder: (context) => const _AreaPickerDialog(),
              );
              if (pickedArea == null || !context.mounted) return;

              // Loading
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const AlertDialog(
                  content: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Expanded(child: Text('Montando simulado 60...')),
                      ],
                    ),
                  ),
                ),
              );

              try {
                final ptAll = await mcqRepo.loadPortuguese();
                final matAll = await mcqRepo.loadMath();
                final tecAll = await mcqRepo.loadSpecific(pickedArea.key);

                final app = context.read<AppController>();
                final pt = app.pickNonRepeating(
                  poolKey: 'sim60:${pickedArea.key}:pt',
                  pool: ptAll,
                  count: 10,
                );
                final mat = app.pickNonRepeating(
                  poolKey: 'sim60:${pickedArea.key}:mat',
                  pool: matAll,
                  count: 10,
                );
                final tec = app.pickNonRepeating(
                  poolKey: 'sim60:${pickedArea.key}:tec',
                  pool: tecAll,
                  count: 40,
                );

                final all = <Question>[...pt, ...mat, ...tec];
                // Se algum pool estiver curto, garante no máximo 60 e embaralha.
                all.shuffle();
                final questions = all.length > _questionsPerSimulado60
                    ? all.take(_questionsPerSimulado60).toList(growable: false)
                    : all;

                if (!context.mounted) return;
                Navigator.of(context).pop(); // fecha loading

                if (questions.length < _questionsPerSimulado60) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Banco insuficiente para 60 questões. Gerou ${questions.length}. '
                        'Rode o script para gerar o simulado_mcq.json completo.',
                      ),
                    ),
                  );
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SimuladoScreen(
                      title: 'Simulado 60 • ${pickedArea.label}',
                      questions: questions,
                      mode: 'sim60',
                      subjectId: 'mix',
                    ),
                  ),
                );
              } catch (_) {
                if (!context.mounted) return;
                Navigator.of(context).pop(); // fecha loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Falha ao ler assets/questions/simulado_mcq.json.')),
                );
              }
            },
          ),
          ...app.subjects.map((s) {
            return _SimuladoCard(
              title: s.title,
              subtitle: '$_questionsPerSimulado questões aleatórias • 60:00',
              enabled: true,
              onStart: () async {
                await _startSimulado(
                  context,
                  title: 'Simulado - ${s.title}',
                  loadQuestions: () => repo.loadForSubjectId(s.id),
                  mode: 'subject',
                  subjectId: s.id,
                );
              },
            );
          }),
          Builder(
            builder: (context) {
              return _SimuladoCard(
                title: 'Misto',
                subtitle: '$_questionsPerSimulado questões aleatórias • 60:00',
                enabled: true,
                onStart: () async {
                  await _startSimulado(
                    context,
                    title: 'Simulado - Misto',
                    loadQuestions: repo.loadMixed,
                    mode: 'mixed',
                    subjectId: null,
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
                  Text('Cebraspe: +1 certo / -1 errado • Pular: 0'),
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

class _AreaPickerDialog extends StatefulWidget {
  const _AreaPickerDialog();

  @override
  State<_AreaPickerDialog> createState() => _AreaPickerDialogState();
}

class _AreaPickerDialogState extends State<_AreaPickerDialog> {
  SimuladoArea? _selected = SimuladoAreas.operacao;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Área de atuação'),
      content: DropdownButtonFormField<SimuladoArea>(
        value: _selected,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        items: [
          for (final a in SimuladoAreas.all)
            DropdownMenuItem(value: a, child: Text(a.label)),
        ],
        onChanged: (v) => setState(() => _selected = v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('Iniciar'),
        ),
      ],
    );
  }
}
