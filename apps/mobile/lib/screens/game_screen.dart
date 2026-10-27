import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/fake_data.dart';
import 'package:domain/domain.dart';

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
    final List<Game> displayGames;

    if (_searchQuery.isNotEmpty) {
      displayGames = fakeGames.where((game) {
        return game.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    } else {
      displayGames = fakeGames.take(_visibleCount).toList();
    }

    final bool isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
      ),
      body: Center(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  itemCount: displayGames.length + (isSearching ? 0 : 1),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (!isSearching && index == displayGames.length) {
                      if (fakeGames.length > _visibleCount) {
                        return Center(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _visibleCount += 10);
                            },
                            child: const Text('Show more'),
                          ),
                        );
                      }

                      if(_visibleCount > 3)
                        {
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
                                game.genre,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Chip(
                                    label: Text('Year: ${game.releaseDate.year}'),
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
            ],
          ),
        ),
      ),
    );
  }
}