import 'package:flutter/material.dart';
import '../models/ranking_rules.dart';
import '../data/fake_data.dart';
import '../models/leaderboard_entry.dart';
import '../widgets/leaderboard_entry_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final game = fakeGames.firstWhere((g) => g.id == gameId);

    final entries = fakeEntries.where((e) => e.gameId == gameId && e.status is Approved).toList();

    entries.sort((a, b)
    {
      if(game.rules.rankingOrder == RankingOrder.descending)
        {
          return b.score.compareTo(a.score);
        }
      else
        {
          return a.score.compareTo(b.score);
        }
    });

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
      )
    );
  }
}