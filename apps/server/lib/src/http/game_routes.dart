import 'package:relic/relic.dart';
import 'package:scoreboard_api/scoreboard_api.dart';

import 'package:server/src/app_services.dart';
import 'package:server/src/http/auth.dart';
import 'package:server/src/http/error_handling.dart';
import 'package:server/src/http/server_api_exception.dart';

const _gameId = IntPathParam(#gameId);

void registerGameRoutes(RelicApp app, AppServices services) {
  app.get(RoutePatterns.health, (request) async =>
      jsonResponse({'status': 'ok'}));

  app.get(RoutePatterns.games, (request) async {
    await requireAuth(request, services);
    final games = await services.scores.listGames();
    return jsonResponse(games.map((g) => g.toJson()).toList());
  });

  app.get(RoutePatterns.game, (request) async {
    await requireAuth(request, services);
    final gameId = request.pathParameters.get(_gameId);
    final game = await services.scores.game(gameId);
    if (game == null) {
      throw const ServerApiException.notFound('The game does not exist.');
    }
    return jsonResponse(game.toJson());
  });

  app.get(RoutePatterns.board, (request) async {
    await requireAuth(request, services);
    final gameId = request.pathParameters.get(_gameId);
    final board = await services.scores.boardForGame(gameId);
    if (board == null) {
      throw const ServerApiException.notFound('The game does not exist.');
    }
    return jsonResponse(board.toJson());
  });

  app.get(RoutePatterns.leaderboard, (request) async {
    await requireAuth(request, services);
    final gameId = request.pathParameters.get(_gameId);
    final board = await services.scores.boardForGame(gameId);
    if (board == null) {
      throw const ServerApiException.notFound('The game does not exist.');
    }
    final leaderboard = await services.scores.leaderboard(gameId);
    return jsonResponse(leaderboard.map((s) => s.toJson()).toList());
  });
}
