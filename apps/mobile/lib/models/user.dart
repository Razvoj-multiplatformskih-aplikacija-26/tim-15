enum Role { guest, admin }

class User {
  final String id;
  final String username;
  final Role role;
  final bool active;

  const User({
    required this.id,
    required this.username,
    required this.role,
    this.active = true,
  });
}