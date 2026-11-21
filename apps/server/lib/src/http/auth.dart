import 'dart:convert';

import 'package:relic/relic.dart';

import 'package:server/src/app_services.dart';
import 'package:server/src/authenticated_user.dart';
import 'package:server/src/http/server_api_exception.dart';

Future<AuthenticatedUser> requireAuth(
  Request request,
  AppServices services,
) async {
  final header = request.headers.authorization;
  final token = header is BearerAuthorizationHeader ? header.token : null;
  if (token == null || token.isEmpty) {
    throw const ServerApiException.unauthorized();
  }
  final session = await services.sessions
      .consume(token, services.sessionTtlSeconds);
  if (session == null) {
    throw const ServerApiException.unauthorized(
        'Your session has expired. Please sign in again.');
  }
  final user = await services.users.findById(session.userId);
  if (user == null || !user.active) {
    throw const ServerApiException.userDisabled(
        'Your account is disabled. Please contact an administrator.');
  }
  return AuthenticatedUser(user: user, token: token);
}

AuthenticatedUser requireAdmin(AuthenticatedUser actor) {
  if (!actor.isAdmin) {
    throw const ServerApiException.forbidden(
        'Only administrators can do this.');
  }
  return actor;
}

Map<String, dynamic> decodeJsonBody(String raw) {
  if (raw.trim().isEmpty) {
    throw const ServerApiException.validation(
        'The request body must be valid JSON.');
  }
  Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    decoded = null;
  }
  if (decoded is Map<String, dynamic>) return decoded;
  throw const ServerApiException.validation(
      'The request body must be valid JSON.');
}

String? nonEmptyString(Map<String, dynamic> body, String key, int maxLength) {
  final value = body[key];
  if (value is! String) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.length > maxLength) return null;
  return trimmed;
}

int? integerBodyValue(Map<String, dynamic> body, String key) {
  final value = body[key];
  if (value is int) return value;
  if (value is num && value == value.truncateToDouble()) {
    return value.toInt();
  }
  if (value is String) return int.tryParse(value);
  return null;
}
