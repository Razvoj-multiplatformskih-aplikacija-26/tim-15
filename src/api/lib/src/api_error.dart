class ApiErrorCode {
  static const invalidCredentials = 'invalid_credentials';
  static const userDisabled = 'user_disabled';
  static const unauthenticated = 'unauthenticated';
  static const forbidden = 'forbidden';
  static const notFound = 'not_found';
  static const validation = 'validation_failed';
  static const overLimit = 'score_over_limit';
  static const conflict = 'conflict';
  static const internal = 'internal_error';
}

final class ApiError {
  const ApiError({required this.code, required this.message});

  final String code;
  final String message;

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        code: json['code'] as String? ?? ApiErrorCode.internal,
        message: json['message'] as String? ?? 'Unknown error.',
      );

  Map<String, dynamic> toJson() => {'code': code, 'message': message};
}
