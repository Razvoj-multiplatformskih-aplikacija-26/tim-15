import 'package:scoreboard_api/src/user_dto.dart';

final class LoginResponse {
  const LoginResponse({required this.token, required this.user});

  final String token;
  final UserDto user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json['token'] as String,
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}
