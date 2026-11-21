import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

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
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthRouterNotifier(auth),
    redirect: (context, state) {
      final authState = auth.state;
      final loggingIn = state.matchedLocation == '/login';
      if (authState is AuthRestoring || authState is AuthInitial) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }
      if (authState is AuthLoggedIn && authState.user.isAdmin) {
        return loggingIn ? '/' : null;
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
      GoRoute(
        path: '/',
        builder: (context, state) {
          final selectedIdStr = state.uri.queryParameters['selected'];
          final selectedId =
              selectedIdStr != null ? int.tryParse(selectedIdStr) : null;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => GamesBloc(repository)..add(const GamesLoad()),
              ),
              BlocProvider(
                create: (_) => MyEntriesBloc(repository)
                  ..add(const MyEntriesLoadAll()),
              ),
            ],
            child: DashboardScreen(selectedId: selectedId),
          );
        },
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
