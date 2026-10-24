import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/fake_data.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: fakeGames.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final game = fakeGames[index];
              return Card(
                child: InkWell(
                  onTap: () => context.push('/games/${game.id}'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                game.name,
                                style: theme.textTheme.headlineSmall,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          game.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text('Metrics: ${game.rules.metricName}'),
                              visualDensity: VisualDensity.compact,
                            ),
                            if (game.rules.participantLimit != null)
                              Chip(
                                label: Text('Top ${game.rules.participantLimit}'),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
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
  }
}