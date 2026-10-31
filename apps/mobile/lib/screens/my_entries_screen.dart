import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../text/serbian.dart';
import '../widgets/status_badge.dart';

class MyEntriesScreen extends StatelessWidget {
  const MyEntriesScreen({super.key});

  Future<void> _withdraw(BuildContext context, int scoreId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Withdraw Score'),
        content: const Text(
            'Are you sure you want to withdraw this score?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context
          .read<MyEntriesBloc>()
          .add(MyEntriesWithdraw(scoreId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Entries')),
      body: BlocListener<MyEntriesBloc, MyEntriesState>(
        listener: (context, state) {
          if (state is MyEntriesWithdrawn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('The score has been withdrawn.')),
            );
          } else if (state is MyEntriesApproved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('The score has been approved.')),
            );
          }
        },
        child: BlocBuilder<MyEntriesBloc, MyEntriesState>(
          builder: (context, state) {
            if (state is MyEntriesWithScores) {
              final myScores = state.scores;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: myScores.isEmpty
                      ? const Center(child: Text('You have no entries yet.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: myScores.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final score = myScores[index];
                            final game = score.board.game;
                            final canWithdraw =
                                score.state != ScoreState.archived &&
                                    score.state != ScoreState.rejected;

                            return Card(
                              child: InkWell(
                                onTap: () =>
                                    context.push('/my-entries/${score.id}'),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              game.name,
                                              style: theme
                                                  .textTheme.titleLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          StatusBadge(
                                              state: score.state),
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
                                        style:
                                            theme.textTheme.bodySmall
                                                ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),

                                      if (canWithdraw) ...[
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment:
                                              Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () => _withdraw(
                                                context, score.id),
                                            icon: const Icon(
                                                Icons.close, size: 18),
                                            label: const Text(
                                                'Withdraw your score'),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  theme.colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],

                                      if (score.state ==
                                          ScoreState.pending) ...[
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment:
                                              Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () => context
                                                .read<MyEntriesBloc>()
                                                .add(
                                                    MyEntriesApprove(
                                                        score.id)),
                                            icon: const Icon(
                                                Icons
                                                    .check_circle_outline,
                                                size: 18),
                                            label: const Text(
                                                'Approve score (simulate)'),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  theme.colorScheme.primary,
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
              );
            }

            if (state is MyEntriesError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context
                          .read<MyEntriesBloc>()
                          .add(const MyEntriesLoad()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
