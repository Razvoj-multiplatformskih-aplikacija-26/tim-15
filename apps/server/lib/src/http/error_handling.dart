import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:relic/relic.dart';
import 'package:scoreboard_api/scoreboard_api.dart';

import 'package:server/src/http/server_api_exception.dart';

const _corsHeaders = {
  'access-control-allow-origin': ['*'],
  'access-control-allow-methods': ['GET, POST, OPTIONS'],
  'access-control-allow-headers': ['authorization, content-type'],
  'access-control-max-age': ['86400'],
};

Headers withCors(Headers headers) => Headers.fromMap({
      ..._corsHeaders,
      ...headers.map((key, value) => MapEntry(key, value)),
    });

Response jsonResponse(Object? body, {int status = 200}) => Response(
      status,
      body: Body.fromString(jsonEncode(body), mimeType: MimeType.json),
      headers: withCors(Headers.empty()),
    );

Response errorResponse(int status, String code, String message) => Response(
      status,
      body: Body.fromString(
        jsonEncode(ApiError(code: code, message: message).toJson()),
        mimeType: MimeType.json,
      ),
      headers: withCors(Headers.empty()),
    );

Handler corsAndErrors(Handler next) {
  return (Request request) async {
    if (request.method == Method.options) {
      return Response.noContent(headers: withCors(Headers.empty()));
    }
    final Result result;
    try {
      result = await next(request);
    } on ServerApiException catch (error) {
      return errorResponse(error.status, error.code, error.message);
    } on ScoreOverLimitException catch (error) {
      return errorResponse(422, ApiErrorCode.overLimit, error.message);
    } on ValidationException catch (error) {
      return errorResponse(422, ApiErrorCode.validation, error.message);
    } on ConflictException catch (error) {
      return errorResponse(409, ApiErrorCode.conflict, error.message);
    } on PermissionDeniedException catch (error) {
      return errorResponse(403, ApiErrorCode.forbidden, error.message);
    } on NotFoundException catch (error) {
      return errorResponse(404, ApiErrorCode.notFound, error.message);
    } on AuthException catch (error) {
      return errorResponse(401, ApiErrorCode.unauthenticated, error.message);
    } on SessionExpiredException catch (error) {
      return errorResponse(401, ApiErrorCode.unauthenticated, error.message);
    } on DomainException catch (error) {
      return errorResponse(500, ApiErrorCode.internal, error.message);
    } on FormatException {
      return errorResponse(400, ApiErrorCode.validation,
          'The request could not be understood.');
    } on Exception {
      return errorResponse(500, ApiErrorCode.internal,
          'Something went wrong. Please try again later.');
    }
    if (result is Response) {
      return Response(result.statusCode,
          body: result.body, headers: withCors(result.headers));
    }
    return result;
  };
}
