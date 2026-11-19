import 'package:relic/relic.dart';

import 'package:server/src/app_services.dart';
import 'package:server/src/config.dart';
import 'package:server/src/db/database.dart';
import 'package:server/src/db/scores_repository.dart';
import 'package:server/src/db/sessions_repository.dart';
import 'package:server/src/db/users_repository.dart';
import 'package:server/src/http/auth_routes.dart';
import 'package:server/src/http/error_handling.dart';
import 'package:server/src/http/game_routes.dart';
import 'package:server/src/http/score_routes.dart';

RelicApp createApp(Database database, Config config) {
  final services = AppServices(
    scores: ScoresRepository(database),
    users: UsersRepository(database),
    sessions: SessionsRepository(database),
  );

  final app = RelicApp()..use('/', corsAndErrors);

  registerAuthRoutes(app, services,
      sessionTtlSeconds: config.sessionTtl.inSeconds);
  registerGameRoutes(app, services);
  registerScoreRoutes(app, services);

  app.fallback = (request) =>
      errorResponse(404, 'not_found', 'The requested endpoint does not exist.');

  return app;
}
