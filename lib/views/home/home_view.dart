import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../data/question_json_repository.dart';
import '../../models/subject.dart';
import '../profile/profile_screen.dart';
import '../quiz/quiz_screen.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const int _questionsPerQuiz = 20;
  static const _bg = Color(0xFFF2F5F7); // cinza azulado muito claro
  static const _primary = Color(0xFF004B39); // Verde Petróleo
  static const _amber = Color(0xFFFFBF00); // CTA / progresso

  Future<void> _startQuiz(
    BuildContext context, {
    required String title,
    required String subjectId,
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
      final all = await repo.loadForSubjectId(subjectId);
      final app = context.read<AppController>();
      final picked = app.pickNonRepeating(
        poolKey: 'quiz:$subjectId',
        pool: all,
        count: _questionsPerQuiz,
      );
      if (!context.mounted) return;
      Navigator.of(context).pop(); // fecha loading

      if (picked.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sem questões para esta matéria no questions.json.')),
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            title: title,
            subjectId: subjectId,
            questions: picked,
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
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final basics = app.subjects.where((s) => s.id == 'pt' || s.id == 'mat').toList(growable: false);
    final technical = app.subjects.where((s) => s.id == 'sms' || s.id == 'tec').toList(growable: false);

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: _bg,
            surfaceTintColor: _bg,
            titleSpacing: 20,
            title: Text(
              'PetroQuest',
              style: (text.titleLarge ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Perfil',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                icon: Icon(
                  PhosphorIconsRegular.userCircle,
                  color: cs.onSurface,
                ),
              ),
              IconButton(
                tooltip: 'Alternar tema',
                onPressed: app.toggleThemeMode,
                icon: Icon(
                  PhosphorIconsRegular.moonStars,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trilhas • Nível Técnico',
                      style: (text.titleMedium ?? const TextStyle()).copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selecione uma matéria e faça um quiz com $_questionsPerQuiz questões aleatórias.',
                      style: (text.bodyMedium ?? const TextStyle()).copyWith(
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: _SectionHeader(
                title: 'Base',
                subtitle: 'Português e Matemática',
                icon: PhosphorIconsRegular.bookOpenText,
              ),
            ),
          ),
          _SubjectsGrid(
            subjects: basics,
            onStart: (s) => _startQuiz(context, title: s.title, subjectId: s.id),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: _SectionHeader(
                title: 'Técnico',
                subtitle: 'SMS e Conhecimentos Específicos',
                icon: PhosphorIconsRegular.hardHat,
              ),
            ),
          ),
          _SubjectsGrid(
            subjects: technical,
            onStart: (s) => _startQuiz(context, title: s.title, subjectId: s.id),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF004B39).withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: const Color(0xFF004B39)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: (text.titleSmall ?? const TextStyle()).copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: (text.bodySmall ?? const TextStyle()).copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubjectsGrid extends StatelessWidget {
  final List<Subject> subjects;
  final Future<void> Function(Subject s) onStart;

  const _SubjectsGrid({
    required this.subjects,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final app = context.watch<AppController>();
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          // Aumenta a altura de cada item para evitar overflow em telas menores.
          mainAxisExtent: 230,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final s = subjects[index];
            final progress = app.progressFor(s.id);
            return _SubjectCard(
              subject: s,
              progress: progress,
              onStart: () async => onStart(s),
            );
          },
          childCount: subjects.length,
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final double progress;
  final VoidCallback? onStart;

  const _SubjectCard({
    required this.subject,
    required this.progress,
    required this.onStart,
  });

  List<Widget> _buildTopicChips(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final topics = subject.topics;
    // Mantém o card compacto para não estourar altura em telas menores.
    final shown = topics.take(1).toList(growable: false);
    final remaining = (topics.length - shown.length).clamp(0, 999);

    final chips = <Widget>[
      for (final t in shown)
        _TopicChip(
          label: t.title,
          isHigh: t.priority == TopicPriority.high,
          textStyle: text.labelSmall ?? const TextStyle(),
        ),
    ];

    if (remaining > 0) {
      chips.add(
        _TopicChip(
          label: '+$remaining',
          isHigh: false,
          isCounter: true,
          textStyle: text.labelSmall ?? const TextStyle(),
        ),
      );
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return _PremiumCard(
      onTap: onStart,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: (text.titleSmall ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF004B39),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${subject.topics.length} tópicos',
              style: (text.bodySmall ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _buildTopicChips(context),
            ),
            const Spacer(),
            _ThinProgressBar(value: progress),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '$pct%',
                  style: (text.labelLarge ?? const TextStyle()).copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFBF00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: onStart,
                    child: const Text('Começar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PremiumCard({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.94),
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final bool isHigh;
  final bool isCounter;
  final TextStyle textStyle;

  const _TopicChip({
    required this.label,
    required this.isHigh,
    required this.textStyle,
    this.isCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipBg = isHigh
        ? const Color(0xFFFFBF00).withOpacity(0.18)
        : isCounter
            ? const Color(0xFF004B39).withOpacity(0.10)
            : const Color(0xFFEEF2F4);
    final chipFg = isHigh
        ? const Color(0xFF8A5C00)
        : isCounter
            ? const Color(0xFF004B39)
            : const Color(0xFF3A4650);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: textStyle.copyWith(
          fontWeight: FontWeight.w600,
          color: chipFg,
        ),
      ),
    );
  }
}

class _ThinProgressBar extends StatelessWidget {
  final double value;

  const _ThinProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    final double v = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: v,
        minHeight: 6,
        backgroundColor: const Color(0xFFE6ECEF),
        valueColor: const AlwaysStoppedAnimation(Color(0xFFFFBF00)),
      ),
    );
  }
}
