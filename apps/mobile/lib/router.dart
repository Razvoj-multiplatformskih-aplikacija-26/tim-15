import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_shell.dart';
import 'screens/game_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/entry_detail_screen.dart';
import 'screens/my_entries_screen.dart';
import 'screens/submit_score_screen.dart';

GoRouter createRouter(Repository repository) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
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
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final gameId = int.parse(state.pathParameters['id']!);
                      return BlocProvider(
                        create: (_) => LeaderboardBloc(repository)
                          ..add(LeaderboardLoad(gameId)),
                        child: const LeaderboardScreen(),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'entries/:entryId',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          final entryId = int.parse(state.pathParameters['entryId']!);
                          return BlocProvider(
                            create: (_) => ScoreDetailBloc(repository)
                              ..add(ScoreDetailLoad(entryId)),
                            child: EntryDetailScreen(entryId: entryId),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'submit',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          final gameId = int.parse(state.pathParameters['id']!);
                          return BlocProvider(
                            create: (_) => SubmitScoreBloc(
                              repository,
                              gameId: gameId,
                            )..add(const SubmitScoreLoad()),
                            child: SubmitScoreScreen(gameId: gameId),
                          );
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
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final entryId = int.parse(state.pathParameters['entryId']!);
                      return BlocProvider(
                        create: (_) => ScoreDetailBloc(repository)
                          ..add(ScoreDetailLoad(entryId)),
                        child: EntryDetailScreen(entryId: entryId),
                      );
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
}
