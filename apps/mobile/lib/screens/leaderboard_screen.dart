import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:domain/domain.dart';
import '../data/fake_data.dart';
import '../widgets/leaderboard_entry_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final gameIdInt = int.parse(gameId);
    final game = fakeGames.firstWhere((g) => g.id == gameIdInt);
    final board = fakeBoards.firstWhere((b) => b.game.id == gameIdInt);

    final entries = board.scores
        .where((s) => s.state == ScoreState.approved)
        .toList();

    entries.sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard - ${game.name}')),
      body: Center(
        child: entries.isEmpty ? const Center(child: Text('No submissions yet')) : ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final rank = index + 1;

              return LeaderboardEntryCard(
                entry: entry,
                rank: rank,
                game: game,
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/games/$gameId/submit'),
        icon: const Icon(Icons.add),
        label: const Text('Add Submission'),
      ),
    );
  }
}