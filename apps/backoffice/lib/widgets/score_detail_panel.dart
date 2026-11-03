import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import '../text/serbian.dart';
import 'status_badge.dart';

class ScoreDetailPanel extends StatelessWidget {
  const ScoreDetailPanel({
    super.key,
    required this.score,
    required this.onApprove,
    required this.onReject,
    required this.onClose,
  });

  final Score score;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = score.board.game;

    return Card(
      margin: const EdgeInsets.all(16),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(game.name, style: theme.textTheme.headlineSmall),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Player: ${score.user.username}', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Result: ${score.score}', style: theme.textTheme.displaySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Status: ', style: theme.textTheme.titleMedium),
              StatusBadge(state: score.state),
            ],
          ),
          const SizedBox(height: 8),
          Text('Date: ${formatDateAndTime(score.createdAt)}'),

          if (score.state == ScoreState.pending) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check),
                label: const Text('Approve (C)'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close),
                label: const Text('Reject (X)'),
                style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            Text(
              'This score has already been ${score.state == ScoreState.approved ? 'approved' : 'rejected'}.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}