import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:domain/domain.dart';

import '../data/fake_data.dart';
import '../text/serbian.dart';
import '../widgets/status_badge.dart';

class MyEntriesScreen extends StatefulWidget {
  const MyEntriesScreen({super.key});

  @override
  State<MyEntriesScreen> createState() => _MyEntriesScreenState();
}

class _MyEntriesScreenState extends State<MyEntriesScreen> {
  Future<void> _withdraw(Score score) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Score'),
        content: const Text('Are you sure you want to withdraw this score?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
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
          const SnackBar(content: Text('The score has been withdrawn.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: fakeDataNotifier,
      builder: (context, child) {
        final myScores = getMyScores();

        return Scaffold(
          appBar: AppBar(title: const Text('My Entries')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: myScores.isEmpty
                  ? const Center(child: Text('You have no entries yet.'))
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: myScores.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final score = myScores[index];
                  final game = score.board.game;
                  final canWithdraw = score.state != ScoreState.archived && score.state != ScoreState.rejected;

                  return Card(
                    child: InkWell(
                      onTap: () => context.push('/my-entries/${score.id}'),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    game.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                StatusBadge(state: score.state),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The result: ${score.score}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sent: ${formatDateAndTime(score.createdAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),

                            if (canWithdraw) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _withdraw(score),
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('Withdraw your score'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],

                            // samo simulacija za sada, dok ne dodam backoffice
                            if (score.state == ScoreState.pending) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      approveScore(score);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('The score has been approved.')),
                                    );
                                  },
                                  icon: const Icon(Icons.check_circle_outline, size: 18),
                                  label: const Text('Approve score (simulate)'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}