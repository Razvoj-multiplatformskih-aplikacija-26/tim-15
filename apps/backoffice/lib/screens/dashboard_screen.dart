import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domain/domain.dart';
import 'package:go_router/go_router.dart';
import '../widgets/score_table.dart';
import '../widgets/score_detail_panel.dart';
import '../shortcuts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.selectedId});

  final int? selectedId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _tableFocus = FocusNode(debugLabel: 'table grid');
  final _searchFocus = FocusNode(debugLabel: 'search bar');
  final _searchController = TextEditingController();
  String _searchQuery = '';

  int get _selectedId => widget.selectedId ?? 0;

  @override
  void dispose() {
    _tableFocus.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _selectScore(int? id) {
    if (id == null) {
      context.go('/');
    } else {
      context.go('/?selected=$id');
    }
    _tableFocus.requestFocus();
  }

  Score? _getSelectedScore(List<Score> scores) {
    if (scores.isEmpty) return null;
    final index = scores.indexWhere((s) => s.id == _selectedId);
    if (index == -1) return scores.first;
    return scores[index];
  }

  void _showShortcutsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('C - Approve score'),
            Text('X - Reject/Withdraw score'),
            Text('↑ / ↓ - Move selection'),
            Text('Esc - Clear selection'),
            Text('R - Refresh data'),
            Text('F1 - Show this dialog'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard Backoffice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh (R)',
            onPressed: () => context.read<MyEntriesBloc>().add(const MyEntriesLoadAll()),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard),
            tooltip: 'Shortcuts (F1)',
            onPressed: _showShortcutsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: InputDecoration(
                hintText: 'Search by player or game...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<MyEntriesBloc, MyEntriesState>(
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
                          onPressed: () => context.read<MyEntriesBloc>().add(const MyEntriesLoadAll()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is MyEntriesWithScores) {
                  final allScores = state.scores;
                  final scores = _searchQuery.isEmpty
                      ? allScores
                      : allScores.where((s) =>
                  s.user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      s.board.game.name.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();

                  if (scores.isEmpty) {
                    return const Center(child: Text('No scores match your search.'));
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 840;
                      final selectedScore = _getSelectedScore(scores);

                      return Shortcuts(
                        shortcuts: appShortcuts,
                        child: Actions(
                          actions: {
                            MoveSelectionIntent: CallbackAction<MoveSelectionIntent>(
                              onInvoke: (intent) {
                                final currentIndex = scores.indexWhere((s) => s.id == _selectedId);
                                final newIndex = (currentIndex + intent.delta).clamp(0, scores.length - 1);
                                if (newIndex != currentIndex) {
                                  _selectScore(scores[newIndex].id);
                                }
                                return null;
                              },
                            ),
                            ApproveIntent: CallbackAction<ApproveIntent>(
                              onInvoke: (_) {
                                final selected = _getSelectedScore(scores);
                                if (selected != null && selected.state == ScoreState.pending) {
                                  context.read<MyEntriesBloc>().add(MyEntriesApprove(selected.id));
                                }
                                return null;
                              },
                            ),
                            RejectIntent: CallbackAction<RejectIntent>(
                              onInvoke: (_) {
                                final selected = _getSelectedScore(scores);
                                if (selected != null && selected.state == ScoreState.pending) {
                                  context.read<MyEntriesBloc>().add(MyEntriesReject(selected.id));
                                }
                                return null;
                              },
                            ),
                            ClearSelectionIntent: CallbackAction<ClearSelectionIntent>(
                              onInvoke: (_) {
                                _selectScore(null);
                                return null;
                              },
                            ),
                            RefreshIntent: CallbackAction<RefreshIntent>(
                              onInvoke: (_) {
                                context.read<MyEntriesBloc>().add(const MyEntriesLoadAll());
                                return null;
                              },
                            ),
                            ShowShortcutsIntent: CallbackAction<ShowShortcutsIntent>(
                              onInvoke: (_) {
                                _showShortcutsDialog();
                                return null;
                              },
                            ),
                          },
                          child: Focus(
                            focusNode: _tableFocus,
                            autofocus: true,
                            child: ListenableBuilder(
                              listenable: _tableFocus,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _tableFocus.hasFocus ? Colors.blue : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                              child: isWide
                                  ? Row(
                                children: [
                                  Expanded(
                                    child: ScoreTable(
                                      scores: scores,
                                      selectedIndex: scores.indexWhere((s) => s.id == _selectedId),
                                      onSelected: (index) {
                                        _selectScore(scores[index].id);
                                      },
                                    ),
                                  ),
                                  if (selectedScore != null) ...[
                                    const VerticalDivider(width: 1),
                                    SizedBox(
                                      width: 340,
                                      child: ScoreDetailPanel(
                                        score: selectedScore,
                                        onApprove: selectedScore.state == ScoreState.pending
                                            ? () => context.read<MyEntriesBloc>().add(MyEntriesApprove(selectedScore.id))
                                            : null,
                                        onReject: () => context.read<MyEntriesBloc>().add(MyEntriesReject(selectedScore.id)),
                                        onClose: () => _selectScore(null),
                                      ),
                                    ),
                                  ],
                                ],
                              )
                                  : Column(
                                children: [
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: scores.length,
                                      separatorBuilder: (_, __) => const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final score = scores[index];
                                        final isSelected = score.id == _selectedId;
                                        return Material(
                                          color: isSelected
                                              ? Theme.of(context).colorScheme.primaryContainer
                                              : null,
                                          child: InkWell(
                                            onTap: () => _selectScore(score.id),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          score.user.username,
                                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        score.board.game.name,
                                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                          color: Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Rezultat: ${score.score}',
                                                        style: Theme.of(context).textTheme.bodyLarge,
                                                      ),
                                                      Text(
                                                        score.state.name.toUpperCase(),
                                                        style: Theme.of(context).textTheme.labelMedium,
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
                                  if (selectedScore != null) ...[
                                    const Divider(height: 1),
                                    SizedBox(
                                      height: 320,
                                      child: ScoreDetailPanel(
                                        score: selectedScore,
                                        onApprove: selectedScore.state == ScoreState.pending
                                            ? () => context.read<MyEntriesBloc>().add(MyEntriesApprove(selectedScore.id))
                                            : null,
                                        onReject: () => context.read<MyEntriesBloc>().add(MyEntriesReject(selectedScore.id)),
                                        onClose: () => _selectScore(null),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}