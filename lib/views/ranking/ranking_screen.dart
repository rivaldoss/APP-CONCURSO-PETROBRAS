import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/app_controller.dart';
import '../../models/ranking_entry.dart';
import '../../services/firebase_bootstrap.dart';
import '../../services/ranking_service.dart';
import '../../services/user_service.dart';
import '../profile/profile_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _service = RankingService();
  final _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking • Plataforma'),
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
      body: StreamBuilder<List<RankingEntry>>(
        stream: _service.watchTop10(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? const <RankingEntry>[];
          final myUid = FirebaseBootstrap.initialized ? FirebaseAuth.instance.currentUser?.uid : null;

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              if (FirebaseBootstrap.initialized)
                StreamBuilder(
                  stream: _userService.watchMe(),
                  builder: (context, meSnap) {
                    final me = meSnap.data;
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
                              child: Icon(Icons.person, color: cs.onPrimaryContainer),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    me?.displayName ?? 'Você',
                                    style: const TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Seu score: ${me?.score ?? 0}'),
                                ],
                              ),
                            ),
                            FutureBuilder<int?>(
                              future: _service.fetchMyRank(),
                              builder: (context, rankSnap) {
                                final rank = rankSnap.data;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: cs.secondaryContainer,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    rank == null ? 'Posição: —' : 'Posição: #$rank',
                                    style: TextStyle(
                                      color: cs.onSecondaryContainer,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.emoji_events, color: cs.onSecondaryContainer),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Top 10', style: TextStyle(fontWeight: FontWeight.w800)),
                            SizedBox(height: 4),
                            Text('Cebraspe: +10 certo / -5 errado.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...List.generate(items.length, (i) {
                final it = items[i];
                return _RankingTile(
                  position: i + 1,
                  name: it.displayName,
                  score: it.score,
                  isMe: myUid != null && it.userId == myUid,
                );
              }),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Sem dados de ranking por enquanto.')),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  final int position;
  final String name;
  final int score;
  final bool isMe;

  const _RankingTile({
    required this.position,
    required this.name,
    required this.score,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTop3 = position <= 3;
    final isTop10 = position <= 10;

    final tierTitle = isTop3
        ? 'Superintendente da Plataforma'
        : isTop10
            ? 'Supervisor de Operação'
            : 'Técnico em Formação';

    final tierIcon = isTop3 ? Icons.emoji_events : isTop10 ? Icons.military_tech : Icons.badge_outlined;
    final tierIconColor = isTop3 ? const Color(0xFFFFD54F) : isTop10 ? const Color(0xFFB0BEC5) : cs.onSurfaceVariant;

    final border = isMe ? cs.primary : cs.outlineVariant;
    final bg = isMe ? cs.primaryContainer.withOpacity(0.35) : cs.surface;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isTop3 ? cs.primaryContainer : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                '$position',
                style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Você',
                            style: TextStyle(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(tierIcon, size: 16, color: tierIconColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tierTitle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$score',
              style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
