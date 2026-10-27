import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_shell.dart';
import 'screens/game_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/entry_detail_screen.dart';
import 'screens/my_entries_screen.dart';
import 'screens/submit_score_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const GamesScreen(),
              routes: [
                GoRoute(
                  path: 'games/:id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final gameId = state.pathParameters['id']!;
                    return LeaderboardScreen(gameId: gameId);
                  },
                  routes: [
                    GoRoute(
                      path: 'entries/:entryId',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final entryId = state.pathParameters['entryId']!;
                        return EntryDetailScreen(entryId: entryId);
                      },
                    ),
                    GoRoute(
                      path: 'submit',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final gameId = int.parse(state.pathParameters['id']!);
                        return SubmitScoreScreen(gameId: gameId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-entries',
              builder: (context, state) => const MyEntriesScreen(),
              routes: [
                GoRoute(
                  path: ':entryId',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final entryId = state.pathParameters['entryId']!;
                    return EntryDetailScreen(entryId: entryId);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);