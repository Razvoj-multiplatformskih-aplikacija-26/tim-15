import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'screens/entry_detail_screen.dart';
import 'screens/game_screen.dart';
import 'screens/home_shell.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_entries_screen.dart';
import 'screens/submit_score_screen.dart';

class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(AuthBloc auth) {
    _subscription = auth.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(Repository repository, {required AuthBloc auth}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: _AuthRouterNotifier(auth),
    redirect: (context, state) {
      final authState = auth.state;
      final loggingIn = state.matchedLocation == '/login';
      if (authState is AuthRestoring || authState is AuthInitial) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }
      if (authState is AuthLoggedIn) {
        return loggingIn || state.matchedLocation == '/splash' ? '/' : null;
      }
      if (loggingIn) return null;
      return '/login';
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => GamesBloc(repository)..add(const GamesLoad()),
            ),
            BlocProvider(
              create: (_) => MyEntriesBloc(repository)
                ..add(const MyEntriesLoad()),
            ),
          ],
          child: HomeShell(shell: shell),
        ),
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
                          final entryId =
                              int.parse(state.pathParameters['entryId']!);
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
                          final gameId =
                              int.parse(state.pathParameters['id']!);
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
                      final entryId =
                          int.parse(state.pathParameters['entryId']!);
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

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
