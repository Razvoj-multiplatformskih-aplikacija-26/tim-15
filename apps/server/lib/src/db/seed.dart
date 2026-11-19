import 'package:bcrypt/bcrypt.dart';

import 'package:server/src/db/database.dart';

Future<void> seedIfEmpty(Database db) async {
  final count = await db.pool.execute('SELECT COUNT(*)::int AS c FROM users');
  if ((count.first.toColumnMap()['c'] as int) > 0) return;

  final hashes = <String, String>{};
  String hashOf(String password) => hashes.putIfAbsent(
        password,
        () => BCrypt.hashpw(password, BCrypt.gensalt()),
      );

  await db.tx((session) async {
    const users = <(String, String, String)>[
      ('gost', 'gost123', 'guest'),
      ('megi', 'megi123', 'guest'),
      ('lena', 'lena123', 'guest'),
      ('masa', 'masa123', 'guest'),
      ('anja', 'anja123', 'guest'),
      ('djordje', 'djordje123', 'guest'),
      ('ivana', 'ivana123', 'guest'),
      ('tara', 'tara123', 'guest'),
      ('filip', 'filip123', 'guest'),
      ('admin', 'admin123', 'admin'),
    ];
    for (final (username, password, role) in users) {
      await session.execute(
        'INSERT INTO users (username, password_hash, role) '
        'VALUES (\$1, \$2, \$3)',
        parameters: [username, hashOf(password), role],
      );
    }

    const games = <(String, String, String)>[
      ('Tetris', 'Puzzle', '1984-01-01'),
      ('Minecraft Speedrun', 'Sandbox', '2011-11-18'),
      ('CS2 Aim Trainer', 'Shooter', '2023-02-28'),
      ('Chess', 'Strategy', '1475-01-01'),
    ];
    for (final (name, genre, date) in games) {
      await session.execute(
        'INSERT INTO games (name, genre, release_date) VALUES (\$1, \$2, \$3)',
        parameters: [name, genre, date],
      );
    }

    const boards = <(String, int)>[
      ('Tetris', 10000),
      ('Minecraft Speedrun', 10000),
      ('CS2 Aim Trainer', 5),
      ('Chess', 100),
    ];
    for (final (gameName, limit) in boards) {
      await session.execute(
        'INSERT INTO boards (game_id, limit_value) '
        'SELECT id, \$1 FROM games WHERE name = \$2',
        parameters: [limit, gameName],
      );
    }

    const scores = <(String, String, int, String)>[
      ('Tetris', 'megi', 15000, 'approved'),
      ('Tetris', 'lena', 18000, 'approved'),
      ('Tetris', 'masa', 9000, 'approved'),
      ('Tetris', 'anja', 4000, 'approved'),
      ('Tetris', 'djordje', 2000, 'approved'),
      ('Tetris', 'ivana', 13000, 'approved'),
      ('Tetris', 'tara', 900, 'approved'),
      ('Tetris', 'gost', 4600, 'pending'),
      ('Tetris', 'lena', 1000, 'rejected'),
      ('Tetris', 'gost', 12000, 'approved'),
      ('Minecraft Speedrun', 'megi', 300, 'approved'),
      ('Minecraft Speedrun', 'lena', 250, 'approved'),
      ('Minecraft Speedrun', 'gost', 400, 'rejected'),
      ('CS2 Aim Trainer', 'megi', 5, 'approved'),
      ('CS2 Aim Trainer', 'anja', 3, 'archived'),
      ('CS2 Aim Trainer', 'gost', 4, 'pending'),
    ];
    for (final (gameName, username, value, state) in scores) {
      await session.execute(
        'INSERT INTO scores (board_id, user_id, value, name, state) '
        'SELECT b.id, u.id, \$1, \$2, \$3 '
        'FROM boards b '
        'JOIN games g ON g.id = b.game_id '
        'CROSS JOIN users u '
        'WHERE g.name = \$4 AND u.username = \$5',
        parameters: [value, 'Submission', state, gameName, username],
      );
    }
  });
}
