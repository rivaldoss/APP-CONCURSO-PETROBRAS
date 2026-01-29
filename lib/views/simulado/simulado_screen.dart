import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/simulado_controller.dart';
import '../../models/question.dart';
import '../../services/score_service.dart';
import '../../services/simulado_history_service.dart';

class SimuladoScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final String mode;
  final String? subjectId;

  const SimuladoScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.mode,
    required this.subjectId,
  });

  @override
  State<SimuladoScreen> createState() => _SimuladoScreenState();
}

class _SimuladoScreenState extends State<SimuladoScreen> {
  late final SimuladoController _controller;
  final _scoreService = ScoreService();
  final _historyService = SimuladoHistoryService();
  bool _finishDialogShown = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _controller = SimuladoController(questions: widget.questions)..start();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!_finishDialogShown && _controller.finished) {
      _finishDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _submitScoreIfNeeded();
        await _showFinishDialog(context);
      });
    }
  }

  Future<void> _submitScoreIfNeeded() async {
    if (_submitted) return;
    _submitted = true;

    final bonus = _controller.remaining.inMinutes.clamp(0, 60);
    final points = _controller.points + bonus;
    await _scoreService.addPoints(points: points);
    await _historyService.addAttempt(
      mode: widget.mode,
      subjectId: widget.subjectId,
      title: widget.title,
      total: _controller.questions.length,
      correct: _controller.correct,
      bonus: bonus,
      points: points,
      remainingSeconds: _controller.remaining.inSeconds,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: _SimuladoView(title: widget.title),
    );
  }

  Future<void> _showFinishDialog(BuildContext context) async {
    final total = _controller.questions.length;
    final correct = _controller.correct;
    final wrong = _controller.wrong;
    final remaining = _controller.remaining;
    final bonus = remaining.inMinutes.clamp(0, 60);
    final points = _controller.points + bonus;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Resultado do Simulado'),
          content: Text(
            'Acertos: $correct • Erros: $wrong • Total: $total\n'
            'Tempo restante: ${_format(remaining)}\n'
            'Pontuação: $points\n'
            'Bônus tempo: +$bonus',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _controller.restart();
                _controller.start();
                _finishDialogShown = false;
                _submitted = false;
              },
              child: const Text('Recomeçar'),
            ),
          ],
        );
      },
    );
  }
}

class _SimuladoView extends StatelessWidget {
  final String title;

  const _SimuladoView({required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimuladoController>();
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
                    _Pill(
                      icon: Icons.timer,
                      text: _format(controller.remaining),
                      background: cs.primaryContainer,
                      foreground: cs.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    _Pill(
                      icon: Icons.bolt,
                      text: 'Pontos: ${controller.points}',
                      background: cs.secondaryContainer,
                      foreground: cs.onSecondaryContainer,
                    ),
                    const Spacer(),
                    Text(
                      '${controller.index + 1}/${controller.questions.length}',
                      style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
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
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: controller.finished ? null : controller.finish,
                    child: const Text('Encerrar'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: controller.canGoNext()
                          ? controller.next
                          : (controller.answered && !controller.canGoNext())
                              ? controller.finish
                              : null,
                      child: Text(controller.canGoNext() ? 'Próxima' : 'Finalizar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final int index;
  final String label;

  const _OptionTile({required this.index, required this.label});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SimuladoController>();
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
        onTap: (answered || controller.finished) ? null : () => controller.selectOption(index),
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

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: foreground, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

String _format(Duration d) {
  final totalSeconds = d.inSeconds.clamp(0, 60 * 60 * 24);
  final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final s = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
