import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../text/serbian.dart';
import '../widgets/status_badge.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final int entryId;

  Future<void> _withdraw(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Withdraw Score'),
        content: const Text(
            'Are you sure you want to withdraw this score? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context
          .read<ScoreDetailBloc>()
          .add(const ScoreDetailWithdraw());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ScoreDetailBloc, ScoreDetailState>(
      listener: (context, state) {
        if (state is ScoreDetailWithdrawn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Score withdrawn successfully.')),
          );
        }
      },
      child: BlocBuilder<ScoreDetailBloc, ScoreDetailState>(
        builder: (context, state) {
          if (state is ScoreDetailNotFound) {
            return Scaffold(
              appBar: AppBar(title: const Text('Submission details')),
              body: const Center(child: Text('Score not found.')),
            );
          }

          if (state is ScoreDetailError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Submission details')),
              body: Center(child: Text(state.message)),
            );
          }

          if (state is! ScoreDetailWithScore) {
            return Scaffold(
              appBar: AppBar(title: const Text('Submission details')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final score = state.score;
          final game = score.board.game;
          final canWithdraw = state is ScoreDetailLoaded &&
              score.state != ScoreState.archived &&
              score.state != ScoreState.rejected;

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
                            subtitle:
                                Text(formatDateAndTime(score.createdAt)),
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
                          onPressed: () => _withdraw(context),
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
        },
      ),
    );
  }
}
