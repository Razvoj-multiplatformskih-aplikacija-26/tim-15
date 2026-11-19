import 'package:postgres/postgres.dart';

import 'package:server/src/db/database.dart';

final class Migration {
  const Migration(this.version, this.description, this.sql);

  final int version;
  final String description;
  final String sql;
}

const List<Migration> migrations = [
  Migration(
    1,
    'Create core schema',
    '''
    CREATE TABLE users (
      id BIGSERIAL PRIMARY KEY,
      username TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      role TEXT NOT NULL CHECK (role IN ('guest', 'admin')),
      active BOOLEAN NOT NULL DEFAULT TRUE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
    CREATE TABLE games (
      id BIGSERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      genre TEXT NOT NULL,
      release_date DATE NOT NULL
    );
    CREATE TABLE boards (
      id BIGSERIAL PRIMARY KEY,
      game_id BIGINT NOT NULL UNIQUE REFERENCES games (id),
      limit_value INTEGER NOT NULL CHECK (limit_value > 0)
    );
    CREATE TABLE scores (
      id BIGSERIAL PRIMARY KEY,
      board_id BIGINT NOT NULL REFERENCES boards (id),
      user_id BIGINT NOT NULL REFERENCES users (id),
      value INTEGER NOT NULL,
      name TEXT NOT NULL,
      state TEXT NOT NULL DEFAULT 'pending'
        CHECK (state IN ('pending', 'approved', 'rejected', 'archived')),
      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      last_modified TIMESTAMPTZ NOT NULL DEFAULT now()
    );
    CREATE INDEX idx_scores_board_state ON scores (board_id, state);
    CREATE INDEX idx_scores_user ON scores (user_id);
    CREATE INDEX idx_scores_created ON scores (created_at);
    CREATE TABLE sessions (
      token TEXT PRIMARY KEY,
      user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      expires_at TIMESTAMPTZ NOT NULL
    );
    CREATE INDEX idx_sessions_user ON sessions (user_id);
    ''',
  ),
];

Future<void> runMigrations(Database db) async {
  await db.tx((session) async {
    await session.execute(
      'CREATE TABLE IF NOT EXISTS schema_migrations ('
      'version INTEGER PRIMARY KEY, '
      'description TEXT NOT NULL, '
      'applied_at TIMESTAMPTZ NOT NULL DEFAULT now())',
      queryMode: QueryMode.simple,
    );
    final appliedRows =
        await session.execute('SELECT version FROM schema_migrations');
    final applied =
        appliedRows.map((row) => row.toColumnMap()['version'] as int).toSet();
    for (final migration in migrations) {
      if (applied.contains(migration.version)) continue;
      await session.execute(migration.sql, queryMode: QueryMode.simple);
      await session.execute(
        'INSERT INTO schema_migrations (version, description) '
        'VALUES (\$1, \$2)',
        parameters: [migration.version, migration.description],
      );
    }
  });
}
