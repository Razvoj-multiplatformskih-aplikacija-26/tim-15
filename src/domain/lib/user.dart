enum Role { guest, admin }

class User {
  const User({
    required this.id,
    required this.username,
    required this.role,
    this.active = true,
  });

  final String id;
  final String username;
  final Role role;
  final bool active;

  bool get isAdmin => role == Role.admin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && other.id == id && other.username == username;

  @override
  int get hashCode => id.hashCode ^ username.hashCode;
}
