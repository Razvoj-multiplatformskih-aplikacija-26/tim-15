import 'package:go_router/go_router.dart';
import 'screens/dashboard_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          final selectedIdStr = state.uri.queryParameters['selected'];
          final selectedId = selectedIdStr != null ? int.tryParse(selectedIdStr) : null;
          return DashboardScreen(selectedId: selectedId);
        },
      ),
    ],
  );
}