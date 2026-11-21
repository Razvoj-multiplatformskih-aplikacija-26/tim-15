import 'dart:convert';
import 'dart:math';

import 'package:server/src/db/database.dart';

final class SessionRecord {
  const SessionRecord({
    required this.token,
    required this.userId,
    required this.expiresAt,
  });

  final String token;
  final int userId;
  final DateTime expiresAt;
}

final class SessionsRepository {
  SessionsRepository(this._db);

  final Database _db;

  Future<SessionRecord> create(int userId, int ttlSeconds) async {
    final token = _generateToken();
    await _db.pool.execute(
      'INSERT INTO sessions (token, user_id, expires_at) '
      'VALUES (\$1, \$2, now() + \$3 * interval \'1 second\')',
      parameters: [token, userId, ttlSeconds],
    );
    final record = await findByToken(token);
    if (record == null) {
      throw StateError('Failed to create session.');
    }
    return record;
  }

  Future<SessionRecord?> consume(String token, int ttlSeconds) async {
    final expiresAt = await _db.tx((session) async {
      final result = await session.execute(
        'SELECT s.token, s.user_id, s.expires_at '
        'FROM sessions s WHERE s.token = \$1 FOR UPDATE',
        parameters: [token],
      );
      if (result.isEmpty) return null;
      final row = result.first.toColumnMap();
      final current = row['expires_at'] as DateTime;
      if (current.isBefore(DateTime.now())) {
        await session
            .execute('DELETE FROM sessions WHERE token = \$1', parameters: [token]);
        return null;
      }
      final next = DateTime.now()
          .toUtc()
          .add(Duration(seconds: ttlSeconds));
      await session
          .execute('UPDATE sessions SET expires_at = \$1 WHERE token = \$2',
              parameters: [next, token]);
      return next;
    });
    if (expiresAt == null) return null;
    final result = await _db.pool.execute(
      'SELECT s.token, s.user_id, s.expires_at FROM sessions s WHERE s.token = \$1',
      parameters: [token],
    );
    if (result.isEmpty) return null;
    final row = result.first.toColumnMap();
    return SessionRecord(
      token: row['token'] as String,
      userId: row['user_id'] as int,
      expiresAt: expiresAt,
    );
  }

  Future<SessionRecord?> findByToken(String token) async {
    final result = await _db.pool.execute(
      'SELECT token, user_id, expires_at FROM sessions WHERE token = \$1',
      parameters: [token],
    );
    if (result.isEmpty) return null;
    final row = result.first.toColumnMap();
    return SessionRecord(
      token: row['token'] as String,
      userId: row['user_id'] as int,
      expiresAt: row['expires_at'] as DateTime,
    );
  }

  Future<void> delete(String token) async {
    await _db.pool
        .execute('DELETE FROM sessions WHERE token = \$1', parameters: [token]);
  }

  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
