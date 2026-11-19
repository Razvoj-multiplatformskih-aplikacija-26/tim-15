enum RoleDto { guest, admin }

extension RoleDtoJson on RoleDto {
  String get wire => name;

  static RoleDto fromWire(String value) =>
      RoleDto.values.firstWhere((e) => e.name == value,
          orElse: () => RoleDto.guest);
}
