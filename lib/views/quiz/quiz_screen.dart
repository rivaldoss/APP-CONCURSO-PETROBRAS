import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/quiz_controller.dart';
import '../../models/question.dart';
import '../../services/score_service.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final String? subjectId;

  const QuizScreen({
    super.key,
    required this.title,
    required this.questions,
    this.subjectId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizController _controller;
  final _scoreService = ScoreService();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _controller = QuizController(questions: widget.questions);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitScoreIfNeeded() async {
    if (_submitted) return;
    _submitted = true;

    await _scoreService.addPoints(points: _controller.points);

    final subjectId = widget.subjectId;
    if (subjectId != null) {
      final app = context.read<AppController>();
      final ratio = widget.questions.isEmpty ? 0.0 : (_controller.correct / widget.questions.length);
      app.setProgress(subjectId, ratio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: _QuizView(
        title: widget.title,
        onFinish: _submitScoreIfNeeded,
        onRestart: () {
          _submitted = false;
          _controller.restart();
        },
      ),
    );
  }
}

class _QuizView extends StatelessWidget {
  final String title;
  final Future<void> Function() onFinish;
  final VoidCallback onRestart;

  const _QuizView({
    required this.title,
    required this.onFinish,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuizController>();
    final q = controller.current;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Questão ${controller.index + 1}/${controller.questions.length}',
                      style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      'Pontos: ${controller.points}',
                      style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(value: controller.progress),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      q.statement,
                      style: const TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                ...List.generate(
                  q.options.length,
                  (i) => _OptionTile(index: i, label: q.options[i]),
                ),
                if (controller.answered && !controller.isCorrect)
                  _QuickExplanationCard(text: q.quickExplanation),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: controller.answered
                      ? () async {
                          if (controller.canGoNext()) {
                            controller.next();
                            return;
                          }
                          await onFinish();
                          await _showFinishDialog(context, onRestart: onRestart);
                        }
                      : null,
                  child: Text(controller.canGoNext() ? 'Próxima' : 'Finalizar'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFinishDialog(
    BuildContext context, {
    required VoidCallback onRestart,
  }) async {
    final controller = context.read<QuizController>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Resultado'),
          content: Text(
            'Acertos: ${controller.correct} • Erros: ${controller.wrong}\n'
            'Pontuação (Cebraspe): ${controller.points}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRestart();
              },
              child: const Text('Recomeçar'),
            ),
          ],
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final int index;
  final String label;

  const _OptionTile({required this.index, required this.label});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuizController>();
    final q = controller.current;
    final cs = Theme.of(context).colorScheme;

    final answered = controller.answered;
    final selected = controller.selectedIndex == index;
    final correct = index == q.correctIndex;

    Color? background;
    Color? border;
    Color? text;
    IconData? icon;

    if (answered) {
      if (correct) {
        background = cs.primaryContainer;
        border = cs.primary;
        text = cs.onPrimaryContainer;
        icon = Icons.check_circle;
      } else if (selected && !correct) {
        background = cs.errorContainer;
        border = cs.error;
        text = cs.onErrorContainer;
        icon = Icons.cancel;
      } else {
        background = cs.surface;
        border = cs.outlineVariant;
        text = cs.onSurface;
      }
    } else {
      background = cs.surface;
      border = cs.outlineVariant;
      text = cs.onSurface;
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: answered ? null : () => controller.selectOption(index),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border ?? Colors.transparent),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.w600)),
              ),
              if (answered && icon != null) ...[
                const SizedBox(width: 10),
                Icon(icon, color: text),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickExplanationCard extends StatelessWidget {
  final String text;

  const _QuickExplanationCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.lightbulb, color: cs.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Explicação Rápida', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(text, style: TextStyle(color: cs.onSurfaceVariant, height: 1.25)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
