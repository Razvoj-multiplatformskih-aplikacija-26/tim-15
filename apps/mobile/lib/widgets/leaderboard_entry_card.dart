import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/leaderboard_entry.dart';
import '../data/fake_data.dart';
import '../text/serbian.dart';

class LeaderboardEntryCard extends StatelessWidget {
const LeaderboardEntryCard({
super.key,
required this.entry,
required this.rank,
required this.game,
});

final LeaderboardEntry entry;
final int rank;
final Game game;

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  Color? rankColor;
  if (rank == 1) rankColor = scheme.tertiary;
  if (rank == 2) rankColor = scheme.secondary;
  if (rank == 3) rankColor = scheme.primary;

  return Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: rankColor?.withValues(alpha: 0.2) ?? scheme.surfaceContainerHighest,
            foregroundColor: rankColor ?? scheme.onSurface,
            radius: 20,
            child: Text(
              '$rank.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: rankColor ?? scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getUsername(entry.userId),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set : ${formatDate(entry.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${entry.score}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
}
