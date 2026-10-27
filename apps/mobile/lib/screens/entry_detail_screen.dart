import 'package:flutter/material.dart';
import 'package:domain/domain.dart';

import '../data/fake_data.dart';
import '../text/serbian.dart';
import '../widgets/status_badge.dart';

class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({super.key, required this.entryId});
  final String entryId;

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  Score? _findScore() {
    for (final board in fakeBoards) {
      try {
        return board.scores.firstWhere((s) => s.id.toString() == widget.entryId);
      } catch (_) {
      }
    }
    return null;
  }

  Future<void> _withdraw(Score score) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Score'),
        content: const Text('Are you sure you want to withdraw this score? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        score.state = ScoreState.archived;
      });

      fakeDataNotifier.notify();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Score withdrawn successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = _findScore();

    if (score == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('Score not found.')),
      );
    }

    final game = score.board.game;
    final canWithdraw = score.state != ScoreState.archived && score.state != ScoreState.rejected;

    return Scaffold(
      appBar: AppBar(title: const Text('Submission details')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                game.name,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Result',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${score.score}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Status'),
                      trailing: StatusBadge(state: score.state),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date'),
                      subtitle: Text(formatDateAndTime(score.createdAt)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Genre'),
                      subtitle: Text(game.genre),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: canWithdraw
          ? SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: OutlinedButton.icon(
              onPressed: () => _withdraw(score),
              icon: const Icon(Icons.close),
              label: const Text('Withdraw Score'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }
}