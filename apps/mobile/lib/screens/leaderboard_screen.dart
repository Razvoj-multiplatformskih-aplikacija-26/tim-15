import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/leaderboard_entry_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Leaderboard')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<LeaderboardBloc>()
                        .add(const LeaderboardReload()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! LeaderboardLoaded) {
          return Scaffold(
            appBar: AppBar(title: const Text('Leaderboard')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final game = state.game;
        final entries = state.scores;

        return Scaffold(
          appBar: AppBar(title: Text('Leaderboard - ${game.name}')),
          body: Center(
            child: entries.isEmpty
                ? const Center(child: Text('No submissions yet'))
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
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
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/games/${game.id}/submit'),
            icon: const Icon(Icons.add),
            label: const Text('Add Submission'),
          ),
        );
      },
    );
  }
}
