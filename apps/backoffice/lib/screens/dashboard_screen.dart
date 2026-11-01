import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domain/domain.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard Backoffice'),
      ),
      body: BlocBuilder<MyEntriesBloc, MyEntriesState>(
        builder: (context, state) {
          if (state is MyEntriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MyEntriesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<MyEntriesBloc>().add(const MyEntriesLoad()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is MyEntriesWithScores) {
            final scores = state.scores;
            if (scores.isEmpty) {
              return const Center(child: Text('No scores available.'));
            }
            return ListView.builder(
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final score = scores[index];
                return ListTile(
                  title: Text('${score.user.username} - ${score.board.game.name}'),
                  subtitle: Text('Result: ${score.score}'),
                  trailing: Text(score.state.name),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}