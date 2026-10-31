import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _visibleCount = 3;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
      ),
      body: BlocBuilder<GamesBloc, GamesState>(
        builder: (context, state) {
          if (state is GamesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<GamesBloc>()
                        .add(const GamesLoad()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is! GamesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final games = state.games;
          final List<Game> displayGames;

          if (_searchQuery.isNotEmpty) {
            displayGames = games.where((game) {
              return game.name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
            }).toList();
          } else {
            displayGames = games.take(_visibleCount).toList();
          }

          final bool isSearching = _searchQuery.isNotEmpty;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search games...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _visibleCount = 10;
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _visibleCount = 3;
                        });
                      },
                    ),
                  ),

                  if (isSearching)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Search results:  "$_searchQuery":',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),

                  Expanded(
                    child: displayGames.isEmpty
                        ? const Center(child: Text('No games found.'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount:
                                displayGames.length + (isSearching ? 0 : 1),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              if (!isSearching &&
                                  index == displayGames.length) {
                                if (games.length > _visibleCount) {
                                  return Center(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() => _visibleCount += 10);
                                      },
                                      child: const Text('Show more'),
                                    ),
                                  );
                                }

                                if (_visibleCount > 3) {
                                  return Center(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() => _visibleCount = 3);
                                      },
                                      child: const Text('Show less'),
                                    ),
                                  );
                                }
                              }

                              final game = displayGames[index];
                              return Card(
                                child: InkWell(
                                  onTap: () =>
                                      context.push('/games/${game.id}'),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                game.name,
                                                style: theme.textTheme
                                                    .headlineSmall,
                                              ),
                                            ),
                                            const Icon(Icons.chevron_right),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          game.genre,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 8,
                                          children: [
                                            Chip(
                                              label: Text(
                                                  'Year: ${game.releaseDate.year}'),
                                              visualDensity:
                                                  VisualDensity.compact,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
