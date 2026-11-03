import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import '../text/serbian.dart';

class ScoreTable extends StatelessWidget {
  const ScoreTable({
    super.key,
    required this.scores,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<Score> scores;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Player', style: headerStyle)),
              Expanded(flex: 3, child: Text('Game', style: headerStyle)),
              Expanded(flex: 2, child: Text('Result', style: headerStyle, textAlign: TextAlign.right)),
              Expanded(flex: 3, child: Text('Status', style: headerStyle, textAlign: TextAlign.center)),
              Expanded(flex: 3, child: Text('Date', style: headerStyle)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: scores.length,
            itemBuilder: (context, index) {
              final score = scores[index];
              final isSelected = index == selectedIndex;

              return Material(
                color: isSelected
                    ? theme.colorScheme.primaryContainer
                    : (index.isEven ? theme.colorScheme.surfaceContainerLowest : null),
                child: InkWell(
                  onTap: () => onSelected(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(score.user.username)),
                        Expanded(flex: 3, child: Text(score.board.game.name)),
                        Expanded(flex: 2, child: Text('${score.score}', textAlign: TextAlign.right)),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(score.state.name.toUpperCase()),
                          ),
                        ),
                        Expanded(flex: 3, child: Text(formatDate(score.createdAt))),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}