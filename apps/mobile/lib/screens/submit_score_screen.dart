import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    context
        .read<SubmitScoreBloc>()
        .add(SubmitScoreSubmit(scoreValue));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SubmitScoreBloc, SubmitScoreState>(
      listener: (context, state) {
        if (state is SubmitScoreSuccess) {
          context.read<MyEntriesBloc>().add(const MyEntriesLoad());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Result is submitted for approval.')),
          );
          context.pop();
        }
      },
      child: BlocBuilder<SubmitScoreBloc, SubmitScoreState>(
        builder: (context, state) {
          if (state is SubmitScoreInitial || state is SubmitScoreLoading) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Add a result - game ${widget.gameId}'),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is SubmitScoreError && state.board == null) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          final Board? board = switch (state) {
            SubmitScoreLoaded(:final board) => board,
            SubmitScoreSubmitting(:final board) => board,
            SubmitScoreSuccess(:final board) => board,
            SubmitScoreError(:final board) => board,
            _ => null,
          };
          if (board == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final game = board.game;
          final error = state is SubmitScoreError ? state : null;
          final isSubmitting = state is SubmitScoreSubmitting;

          return Scaffold(
            appBar: AppBar(
                title: Text('Add a result - ${game.name}')),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (error != null) ...[
                        Text(
                          error.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
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
                    onPressed:
                        isSubmitting ? null : () => _submit(board),
                    child: const Text('Save Result'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
