import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart';
import 'package:scoreboard_api/scoreboard_api.dart';

import 'package:server/src/authenticated_user.dart';
import 'package:server/src/db/database.dart';

const _scoreJoin = '''
  SELECT s.id, s.name, s.created_at, s.last_modified, s.value, s.state,
         b.id AS board_id, b.limit_value AS board_limit,
         g.id AS game_id, g.name AS game_name, g.genre, g.release_date,
         u.id AS user_id, u.username, u.role, u.active
  FROM scores s
  JOIN boards b ON b.id = s.board_id
  JOIN games g ON g.id = b.game_id
  JOIN users u ON u.id = s.user_id
''';

final class ScoresRepository {
  ScoresRepository(this._db);

  final Database _db;

  Future<List<GameDto>> listGames() async {
    final result = await _db.pool.execute(
      'SELECT id, name, genre, release_date FROM games ORDER BY name',
    );
    return result.map((row) => _gameDto(row.toColumnMap())).toList();
  }

  Future<GameDto?> game(int id) async {
    final result = await _db.pool.execute(
      'SELECT id, name, genre, release_date FROM games WHERE id = \$1',
      parameters: [id],
    );
    if (result.isEmpty) return null;
    return _gameDto(result.first.toColumnMap());
  }

  Future<BoardDto?> boardForGame(int gameId) async {
    final result = await _db.pool.execute(
      'SELECT b.id AS board_id, b.limit_value AS board_limit, '
      'g.id AS game_id, g.name AS game_name, g.genre, g.release_date '
      'FROM boards b JOIN games g ON g.id = b.game_id WHERE g.id = \$1',
      parameters: [gameId],
    );
    if (result.isEmpty) return null;
    final row = result.first.toColumnMap();
    return BoardDto(
      id: row['board_id'] as int,
      limit: row['board_limit'] as int,
      game: GameDto(
        id: row['game_id'] as int,
        name: row['game_name'] as String,
        genre: row['genre'] as String,
        releaseDate: (row['release_date'] as DateTime).toUtc(),
      ),
    );
  }

  Future<List<ScoreDto>> leaderboard(int gameId) async {
    final result = await _db.pool.execute(
      '$_scoreJoin WHERE b.game_id = \$1 AND s.state = \'approved\' '
      'ORDER BY s.value DESC',
      parameters: [gameId],
    );
    return result.map((row) => _scoreDto(row.toColumnMap())).toList();
  }

  Future<ScoreDto?> score(int id) async {
    final result = await _db.pool.execute(
      '$_scoreJoin WHERE s.id = \$1',
      parameters: [id],
    );
    if (result.isEmpty) return null;
    return _scoreDto(result.first.toColumnMap());
  }

  Future<List<ScoreDto>> myScores(int userId) async {
    final result = await _db.pool.execute(
      '$_scoreJoin WHERE s.user_id = \$1 '
      'ORDER BY s.created_at DESC, s.id DESC',
      parameters: [userId],
    );
    return result.map((row) => _scoreDto(row.toColumnMap())).toList();
  }

  Future<List<ScoreDto>> allScores() async {
    final result = await _db.pool
        .execute('$_scoreJoin ORDER BY s.created_at DESC, s.id DESC');
    return result.map((row) => _scoreDto(row.toColumnMap())).toList();
  }

  Future<ScoreDto> submit(AuthenticatedUser actor, int gameId, int value) =>
      _db.tx((session) async {
        final boardRows = await session.execute(
          'SELECT b.id, b.limit_value, g.name FROM boards b '
          'JOIN games g ON g.id = b.game_id '
          'WHERE g.id = \$1 FOR UPDATE OF b',
          parameters: [gameId],
        );
        if (boardRows.isEmpty) {
          throw NotFoundException('The game does not exist.');
        }
        final board = boardRows.first.toColumnMap();
        final boardId = board['id'] as int;
        final limit = board['limit_value'] as int;
        final gameName = board['name'] as String;
        final userId = actor.user.id;

        final pending = await session.execute(
          'SELECT id FROM scores WHERE board_id = \$1 AND user_id = \$2 '
          "AND state = 'pending'",
          parameters: [boardId, userId],
        );
        if (pending.isNotEmpty) {
          throw ConflictException(
            'You already have a pending submission for $gameName. '
            'Withdraw it or wait for an admin decision.',
          );
        }

        final problem = validateScoreValue(value: value, maxScore: limit);
        if (problem != null) throw ValidationException(problem);

        final competitors = await session.execute(
          'SELECT value FROM scores WHERE board_id = \$1 AND user_id <> \$2 '
          "AND state = 'approved' ORDER BY value DESC",
          parameters: [boardId, userId],
        );
        if (!ranksInTopResults(
          value: value,
          rankedValues:
              competitors.map((row) => row.toColumnMap()['value'] as int),
          capacity: limit,
        )) {
          throw ConflictException(
            'The $gameName leaderboard is full - your result of $value '
            'does not rank in the top $limit.',
          );
        }

        final previous = await session.execute(
          'SELECT id FROM scores WHERE board_id = \$1 AND user_id = \$2 '
          "AND state = 'approved'",
          parameters: [boardId, userId],
        );
        for (final row in previous) {
          await session.execute(
            "UPDATE scores SET state = 'archived', last_modified = now() "
            'WHERE id = \$1',
            parameters: [row.toColumnMap()['id']],
          );
        }

        final inserted = await session.execute(
          'INSERT INTO scores (board_id, user_id, value, name, state) '
          "VALUES (\$1, \$2, \$3, 'Submission', 'pending') RETURNING id",
          parameters: [boardId, userId, value],
        );
        final newId = inserted.first.toColumnMap()['id'] as int;
        final dto = await _scoreDtoById(session, newId);
        if (dto == null) throw StateError('Failed to read inserted score.');
        return dto;
      });

  Future<void> withdraw(AuthenticatedUser actor, int scoreId) =>
      _db.tx((session) async {
        final rows = await session.execute(
          'SELECT s.id, s.state, s.user_id FROM scores s '
          'WHERE s.id = \$1 FOR UPDATE OF s',
          parameters: [scoreId],
        );
        if (rows.isEmpty) {
          throw NotFoundException('The submission does not exist.');
        }
        final row = rows.first.toColumnMap();
        final owner = row['user_id'] as int;
        if (!actor.isAdmin && owner != actor.user.id) {
          throw PermissionDeniedException(
            'You can only withdraw your own submissions.',
          );
        }
        final state = _state(row['state'] as String);
        if (!canWithdraw(state)) {
          throw ConflictException(
              'This submission can no longer be withdrawn.');
        }
        await session.execute(
          "UPDATE scores SET state = 'archived', last_modified = now() "
          'WHERE id = \$1',
          parameters: [scoreId],
        );
      });

  Future<void> decide(
      AuthenticatedUser actor, int scoreId, String newState) =>
      _db.tx((session) async {
        final rows = await session.execute(
          'SELECT s.id, s.state FROM scores s '
          'WHERE s.id = \$1 FOR UPDATE OF s',
          parameters: [scoreId],
        );
        if (rows.isEmpty) {
          throw NotFoundException('The submission does not exist.');
        }
        final state = _state(rows.first.toColumnMap()['state'] as String);
        if (!canDecide(state)) {
          throw ConflictException(
            'Only pending submissions can be approved or rejected.',
          );
        }
        final affected = await session.execute(
          "UPDATE scores SET state = \$1, last_modified = now() "
          "WHERE id = \$2 AND state = 'pending'",
          parameters: [newState, scoreId],
        );
        if (affected.affectedRows == 0) {
          throw ConflictException(
            'Only pending submissions can be approved or rejected.',
          );
        }
      });

  Future<ScoreDto?> _scoreDtoById(TxSession session, int id) async {
    final result = await session.execute(
      '$_scoreJoin WHERE s.id = \$1',
      parameters: [id],
    );
    if (result.isEmpty) return null;
    return _scoreDto(result.first.toColumnMap());
  }

  ScoreState _state(String value) => switch (value) {
        'approved' => ScoreState.approved,
        'rejected' => ScoreState.rejected,
        'archived' => ScoreState.archived,
        _ => ScoreState.pending,
      };

  GameDto _gameDto(Map<String, dynamic> row) => GameDto(
        id: row['id'] as int,
        name: row['name'] as String,
        genre: row['genre'] as String,
        releaseDate: (row['release_date'] as DateTime).toUtc(),
      );

  ScoreDto _scoreDto(Map<String, dynamic> row) => ScoreDto(
        id: row['id'] as int,
        name: row['name'] as String,
        createdAt: (row['created_at'] as DateTime).toUtc(),
        lastModified: (row['last_modified'] as DateTime).toUtc(),
        value: row['value'] as int,
        state: switch (row['state'] as String) {
              'approved' => ScoreStateDto.approved,
              'rejected' => ScoreStateDto.rejected,
              'archived' => ScoreStateDto.archived,
              _ => ScoreStateDto.pending,
            },
        board: BoardDto(
          id: row['board_id'] as int,
          limit: row['board_limit'] as int,
          game: GameDto(
            id: row['game_id'] as int,
            name: row['game_name'] as String,
            genre: row['genre'] as String,
            releaseDate: (row['release_date'] as DateTime).toUtc(),
          ),
        ),
        user: UserDto(
          id: (row['user_id'] as int).toString(),
          username: row['username'] as String,
          role:
              (row['role'] as String) == 'admin' ? RoleDto.admin : RoleDto.guest,
          active: row['active'] as bool,
        ),
      );
}
