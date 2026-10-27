import 'package:flutter/material.dart';
import 'package:domain/domain.dart';
import '../theme/theme.dart';

extension ScoreStateLabel on ScoreState {
  String get label => switch (this) {
    ScoreState.pending => 'Pending',
    ScoreState.approved => 'Approved',
    ScoreState.rejected => 'Rejected',
    ScoreState.archived => 'Archived',
  };
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.state});

  final ScoreState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.statusColors;

    final (background, foreground) = switch (state) {
      ScoreState.pending => (colors.pending, colors.onPending),
      ScoreState.approved => (colors.approved, colors.onApproved),
      ScoreState.rejected => (colors.rejected, colors.onRejected),
      ScoreState.archived => (colors.archived, colors.onArchived),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        state.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}