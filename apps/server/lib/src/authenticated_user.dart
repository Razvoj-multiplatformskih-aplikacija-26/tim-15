import 'package:server/src/db/users_repository.dart';

final class AuthenticatedUser {
  const AuthenticatedUser({required this.user, required this.token});

  final UserRecord user;
  final String token;

  bool get isAdmin => user.role == 'admin';
}
