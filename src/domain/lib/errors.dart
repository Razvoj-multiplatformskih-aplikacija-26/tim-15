import 'package:domain/board.dart';

abstract class DomainException implements Exception {
  final String message;

  DomainException(this.message);

  @override
  String toString() => 'DomainError: $message';
}

class ScoreOverLimitException extends DomainException {
  ScoreOverLimitException(super.message, this.score);

  final Score score;
}

class PermissionDeniedException extends DomainException {
  PermissionDeniedException(super.message);
}

class NotFoundException extends DomainException {
  NotFoundException(super.message);
}

class ValidationException extends DomainException {
  ValidationException(super.message);
}

class ConflictException extends DomainException {
  ConflictException(super.message);
}

class AuthException extends DomainException {
  AuthException(super.message);
}

class SessionExpiredException extends DomainException {
  SessionExpiredException(super.message);
}

class NetworkException extends DomainException {
  NetworkException(super.message);
}

class ServerErrorException extends DomainException {
  ServerErrorException(super.message);
}
