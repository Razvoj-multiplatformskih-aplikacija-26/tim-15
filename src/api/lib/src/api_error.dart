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

class ApiErrorRule {
  static const scoreRange = 'score_range';
  static const leaderboardCapacity = 'leaderboard_capacity';
}

final class ApiError {
  const ApiError({
    required this.code,
    required this.message,
    this.details = const {},
  });

  final String code;
  final String message;
  final Map<String, dynamic> details;

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['details'];
    return ApiError(
      code: json['code'] as String? ?? ApiErrorCode.internal,
      message: json['message'] as String? ?? 'Unknown error.',
      details: rawDetails is Map
          ? Map<String, dynamic>.from(rawDetails)
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        if (details.isNotEmpty) 'details': details,
      };
}
