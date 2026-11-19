import 'package:server/src/db/database.dart';

final class UserRecord {
  const UserRecord({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
    required this.active,
  });

  final int id;
  final String username;
  final String passwordHash;
  final String role;
  final bool active;
}

final class UsersRepository {
  UsersRepository(this._db);

  final Database _db;

  Future<UserRecord?> findByUsername(String username) async {
    final result = await _db.pool.execute(
      'SELECT id, username, password_hash, role, active '
      'FROM users WHERE username = \$1',
      parameters: [username],
    );
    if (result.isEmpty) return null;
    return _map(result.first.toColumnMap());
  }

  Future<UserRecord?> findById(int id) async {
    final result = await _db.pool.execute(
      'SELECT id, username, password_hash, role, active FROM users WHERE id = \$1',
      parameters: [id],
    );
    if (result.isEmpty) return null;
    return _map(result.first.toColumnMap());
  }

  Future<int> count() async {
    final result = await _db.pool.execute('SELECT COUNT(*)::int AS count FROM users');
    return result.first.toColumnMap()['count'] as int;
  }

  UserRecord _map(Map<String, dynamic> row) => UserRecord(
        id: row['id'] as int,
        username: row['username'] as String,
        passwordHash: row['password_hash'] as String,
        role: row['role'] as String,
        active: row['active'] as bool,
      );
}
