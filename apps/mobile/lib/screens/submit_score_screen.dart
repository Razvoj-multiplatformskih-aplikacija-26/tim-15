import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:domain/domain.dart';

import '../data/fake_data.dart';

class SubmitScoreScreen extends StatefulWidget {
  const SubmitScoreScreen({super.key, required this.gameId});
  final int gameId;

  @override
  State<SubmitScoreScreen> createState() => _SubmitScoreScreenState();
}

class _SubmitScoreScreenState extends State<SubmitScoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }
  void _submit(Board board) {
    if (!_formKey.currentState!.validate()) return;

    final scoreValue = int.parse(_scoreController.text);
    final now = DateTime.now();

    final newScore = Score(
      id: now.microsecondsSinceEpoch,
      name: 'My Score',
      createdAt: now,
      lastModified: now,
      score: scoreValue,
      board: board,
      user: currentUser,
    );
    newScore.state = ScoreState.pending;

    board.scores.add(newScore);

    fakeDataNotifier.notify();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result is submitted for approval.')),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final board = fakeBoards.firstWhere((b) => b.game.id == widget.gameId);
    final game = board.game;

    return Scaffold(
      appBar: AppBar(title: Text('Add a result - ${game.name}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Add your current score ${game.name}.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Max result for this leaderboard is ${board.limit}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _scoreController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Result',
                    hintText: 'Add your result here',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'The result cannot be empty.';
                    }
                    final score = int.tryParse(value);
                    if (score == null) {
                      return 'Add a valid number.';
                    }
                    if (score < 0) {
                      return 'The result cannot be negative.';
                    }
                    if (score > board.limit) {
                      return 'The result cant be bigger than ${board.limit}.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: FilledButton(
              onPressed: () => _submit(board),
              child: const Text('Save Result'),
            ),
          ),
        ),
      ),
    );
  }
}