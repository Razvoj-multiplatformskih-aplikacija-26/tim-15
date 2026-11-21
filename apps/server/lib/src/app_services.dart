import 'package:server/src/db/scores_repository.dart';
import 'package:server/src/db/sessions_repository.dart';
import 'package:server/src/db/users_repository.dart';

final class AppServices {
  const AppServices({
    required this.scores,
    required this.users,
    required this.sessions,
    required this.sessionTtlSeconds,
  });

  final ScoresRepository scores;
  final UsersRepository users;
  final SessionsRepository sessions;
  final int sessionTtlSeconds;
}
