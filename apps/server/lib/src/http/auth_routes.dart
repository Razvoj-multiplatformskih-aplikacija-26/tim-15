import 'package:bcrypt/bcrypt.dart';
import 'package:relic/relic.dart';
import 'package:scoreboard_api/scoreboard_api.dart';

import 'package:server/src/app_services.dart';
import 'package:server/src/http/auth.dart';
import 'package:server/src/http/error_handling.dart';
import 'package:server/src/http/server_api_exception.dart';
import 'package:server/src/http/user_dto_extension.dart';

void registerAuthRoutes(
  RelicApp app,
  AppServices services, {
  required int sessionTtlSeconds,
}) {
  app.post(RoutePatterns.login, (request) async {
    final body = decodeJsonBody(await request.readAsString());
    final username = nonEmptyString(body, 'username', 64);
    if (username == null) {
      throw const ServerApiException.validation('Please enter a username.');
    }
    final password = body['password'];
    if (password is! String || password.isEmpty) {
      throw const ServerApiException.validation(
          'Please enter a password.');
    }
    final user = await services.users.findByUsername(username.toLowerCase());
    if (user == null || !BCrypt.checkpw(password, user.passwordHash)) {
      throw const ServerApiException.invalidCredentials();
    }
    if (!user.active) {
      throw const ServerApiException.userDisabled(
          'Your account is disabled. Please contact an administrator.');
    }
    final session =
        await services.sessions.create(user.id, sessionTtlSeconds);
    return jsonResponse(
      LoginResponse(token: session.token, user: user.toUserDto()).toJson(),
    );
  });

  app.post(RoutePatterns.logout, (request) async {
    final actor = await requireAuth(request, services);
    await services.sessions.delete(actor.token);
    return Response.noContent();
  });

  app.get(RoutePatterns.me, (request) async {
    final actor = await requireAuth(request, services);
    return jsonResponse(actor.user.toUserDto().toJson());
  });
}
