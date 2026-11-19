import 'package:scoreboard_api/src/role_dto.dart';

final class UserDto {
  const UserDto({
    required this.id,
    required this.username,
    required this.role,
    required this.active,
  });

  final String id;
  final String username;
  final RoleDto role;
  final bool active;

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        username: json['username'] as String,
        role: RoleDtoJson.fromWire(json['role'] as String),
        active: json['active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role.wire,
        'active': active,
      };
}
