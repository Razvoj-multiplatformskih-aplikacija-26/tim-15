import 'package:scoreboard_api/scoreboard_api.dart';

import 'package:server/src/db/users_repository.dart';

extension UserRecordDto on UserRecord {
  UserDto toUserDto() => UserDto(
        id: id.toString(),
        username: username,
        role: role == 'admin' ? RoleDto.admin : RoleDto.guest,
        active: active,
      );
}
