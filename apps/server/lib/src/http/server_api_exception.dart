import 'package:scoreboard_api/scoreboard_api.dart';

class ServerApiException implements Exception {
  const ServerApiException({
    required this.status,
    required this.code,
    required this.message,
  });

  final int status;
  final String code;
  final String message;

  const ServerApiException.unauthorized([
    String message = 'Please sign in to continue.',
  ]) : this(status: 401, code: ApiErrorCode.unauthenticated, message: message);

  const ServerApiException.invalidCredentials([
    String message = 'Wrong username or password.',
  ]) : this(
          status: 401,
          code: ApiErrorCode.invalidCredentials,
          message: message,
        );

  const ServerApiException.userDisabled([
    String message = 'This account is disabled.',
  ]) : this(
          status: 403,
          code: ApiErrorCode.userDisabled,
          message: message,
        );

  const ServerApiException.forbidden([
    String message = 'You do not have permission to do this.',
  ]) : this(status: 403, code: ApiErrorCode.forbidden, message: message);

  const ServerApiException.notFound([
    String message = 'The resource could not be found.',
  ]) : this(status: 404, code: ApiErrorCode.notFound, message: message);

  const ServerApiException.validation([
    String message = 'Invalid input.',
  ]) : this(status: 422, code: ApiErrorCode.validation, message: message);

  const ServerApiException.overLimit([
    String message = 'The result is not valid.',
  ]) : this(status: 422, code: ApiErrorCode.overLimit, message: message);

  const ServerApiException.conflict([
    String message = 'This action conflicts with the current state.',
  ]) : this(status: 409, code: ApiErrorCode.conflict, message: message);

  const ServerApiException.internal([
    String message = 'Something went wrong. Please try again later.',
  ]) : this(status: 500, code: ApiErrorCode.internal, message: message);
}
