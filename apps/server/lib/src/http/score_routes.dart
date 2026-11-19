import 'package:relic/relic.dart';
import 'package:scoreboard_api/scoreboard_api.dart';

import 'package:server/src/app_services.dart';
import 'package:server/src/http/auth.dart';
import 'package:server/src/http/error_handling.dart';
import 'package:server/src/http/server_api_exception.dart';

const _scoreId = IntPathParam(#scoreId);
const _gameId = IntPathParam(#gameId);

void registerScoreRoutes(RelicApp app, AppServices services) {
  app.get(RoutePatterns.myScores, (request) async {
    final actor = await requireAuth(request, services);
    final mine = await services.scores.myScores(actor.user.id);
    return jsonResponse(mine.map((s) => s.toJson()).toList());
  });

  app.get(RoutePatterns.scores, (request) async {
    requireAdmin(await requireAuth(request, services));
    final all = await services.scores.allScores();
    return jsonResponse(all.map((s) => s.toJson()).toList());
  });

  app.get(RoutePatterns.score, (request) async {
    await requireAuth(request, services);
    final id = request.pathParameters.get(_scoreId);
    final score = await services.scores.score(id);
    if (score == null) {
      throw const ServerApiException.notFound(
          'The submission does not exist.');
    }
    return jsonResponse(score.toJson());
  });

  app.post(RoutePatterns.submit, (request) async {
    final actor = await requireAuth(request, services);
    final gameId = request.pathParameters.get(_gameId);
    final body = decodeJsonBody(await request.readAsString());
    final value = integerBodyValue(body, 'value');
    if (value == null) {
      throw const ServerApiException.validation(
          'The result must be a number.');
    }
    final score = await services.scores.submit(actor, gameId, value);
    return jsonResponse(score.toJson(), status: 201);
  });

  app.post(RoutePatterns.withdraw, (request) async {
    final actor = await requireAuth(request, services);
    final id = request.pathParameters.get(_scoreId);
    await services.scores.withdraw(actor, id);
    return Response.noContent();
  });

  app.post(RoutePatterns.approve, (request) async {
    final actor = requireAdmin(await requireAuth(request, services));
    final id = request.pathParameters.get(_scoreId);
    await services.scores.decide(actor, id, 'approved');
    return Response.noContent();
  });

  app.post(RoutePatterns.reject, (request) async {
    final actor = requireAdmin(await requireAuth(request, services));
    final id = request.pathParameters.get(_scoreId);
    await services.scores.decide(actor, id, 'rejected');
    return Response.noContent();
  });
}
