import '../models/game.dart';
import '../models/leaderboard_entry.dart';
import '../models/user.dart';
import '../models/ranking_rules.dart';

const currentUser = User(
  id: 'u-1',
  username: 'gost',
  role: Role.guest,
);

final fakeGames = <Game>[
  const Game(
    id: 'g-1',
    name: 'Tetris',
    description: 'Get as much points as u can',
    rules: LeaderboardRules(
      metricName: 'Points',
      rankingOrder: RankingOrder.descending,
      minimumValue: 0,
      maximumValue: 999999,
      participantLimit: 10,
    ),
  ),
  const Game(
    id: 'g-2',
    name: 'Minecraft Speedrun',
    description: 'Defeat the Ender Dragon as soon as possible',
    rules: LeaderboardRules(
      metricName: 'Time (in seconds)',
      rankingOrder: RankingOrder.ascending,
      minimumValue: 100,
      maximumValue: 7200,
      participantLimit: null,
    ),
  ),
  const Game(
    id: 'g-3',
    name: 'CS2 Aim Trainer',
    description: 'Hit as many targets as possible in 60 seconds',
    rules: LeaderboardRules(
      metricName: 'Points',
      rankingOrder: RankingOrder.descending,
      minimumValue: 0,
      maximumValue: 1000,
      participantLimit: 5,
    ),
  ),
];

final DateTime _now = DateTime.now();

DateTime _daysAgo(int days) => _now.subtract(Duration(days: days));

final fakeUsers = <User>[
  currentUser,
  const User(id: 'u-1', username: 'Vera', role: Role.guest),
  const User(id: 'u-2', username: 'Lena', role: Role.guest),
  const User(id: 'u-3', username: 'Masa', role: Role.guest),
  const User(id: 'u-4', username: 'Anja', role: Role.guest),
  const User(id: 'u-5', username: 'Djordje', role: Role.guest),
  const User(id: 'u-6', username: 'Ivana', role: Role.guest),
  const User(id: 'u-7', username: 'Tara', role: Role.guest),
  const User(id: 'u-8', username: 'Filip', role: Role.guest),
  const User(id: 'u-9', username: 'Ognjen', role: Role.guest),
  const User(id: 'u-10', username: 'Teodora', role: Role.guest),
];

final fakeEntries = <LeaderboardEntry>[
 //tetris
  LeaderboardEntry(
    id: 'e-1',
    gameId: 'g-1',
    userId: 'u-2',
    score: 15000,
    status: Approved(_daysAgo(2)),
    createdAt: _daysAgo(3),
  ),
  LeaderboardEntry(
    id: 'e-2',
    gameId: 'g-1',
    userId: currentUser.id,
    score: 12000,
    status:Approved(_daysAgo(2)),
    createdAt: _daysAgo(1),
  ),
  LeaderboardEntry(
    id: 'e-3',
    gameId: 'g-1',
    userId: 'u-3',
    score: 18000,
    status: Approved(_daysAgo(2)),
    createdAt: _daysAgo(5),
  ),
  LeaderboardEntry(
    id: 'e-4',
    gameId: 'g-1',
    userId: 'u-4',
    score: 9000,
    status:Approved(_daysAgo(2)),
    createdAt: _daysAgo(12),
  ),
  LeaderboardEntry(
    id: 'e-5',
    gameId: 'g-1',
    userId: 'u-5',
    score: 4000,
    status:Approved(_daysAgo(2)),
    createdAt: _daysAgo(12),
  ),
  LeaderboardEntry(
    id: 'e-6',
    gameId: 'g-1',
    userId: 'u-6',
    score: 2000,
    status:Approved(_daysAgo(2)),
    createdAt: _daysAgo(12),
  ),
  LeaderboardEntry(
    id: 'e-7',
    gameId: 'g-1',
    userId: 'u-7',
    score: 13000,
    status:Approved(_daysAgo(2)),
    createdAt: _daysAgo(12),
  ),
  LeaderboardEntry(
    id: 'e-8',
    gameId: 'g-1',
    userId: 'u-8',
    score: 900,
    status:Approved(_daysAgo(2)),
    createdAt: _daysAgo(12),
  ),
  LeaderboardEntry(
    id: 'e-9',
    gameId: 'g-1',
    userId: 'u-9',
    score: 4600,
    status:Approved(_daysAgo(2)),
    createdAt: _daysAgo(12),
  ),
  LeaderboardEntry(
    id: 'e-10',
    gameId: 'g-1',
    userId: 'u-10',
    score: 1000,
    status:Approved(_daysAgo(2)),
    createdAt: _daysAgo(12),
  ),


  // minecraft
  LeaderboardEntry(
    id: 'e-5',
    gameId: 'g-2',
    userId: 'u-2',
    score: 300,
    status: Approved(_daysAgo(1)),
    createdAt: _daysAgo(2),
  ),
  LeaderboardEntry(
    id: 'e-6',
    gameId: 'g-2',
    userId: 'u-3',
    score: 250,
    status: Approved(_daysAgo(3)),
    createdAt: _daysAgo(4),
  ),
  LeaderboardEntry(
    id: 'e-7',
    gameId: 'g-2',
    userId: currentUser.id,
    score: 400,
    status: Rejected('Too slow', _daysAgo(2)),
    createdAt: _daysAgo(3),
  ),
  LeaderboardEntry(
    id: 'e-8',
    gameId: 'g-2',
    userId: 'u-4',
    score: 150,
    status: const Pending(),
    createdAt: _daysAgo(1),
  ),

  //cs2
  LeaderboardEntry(
    id: 'e-9',
    gameId: 'g-3',
    userId: currentUser.id,
    score: 850,
    status: Approved(_daysAgo(1)),
    createdAt: _daysAgo(2),
  ),
  LeaderboardEntry(
    id: 'e-10',
    gameId: 'g-3',
    userId: 'u-2',
    score: 950,
    status: Approved(_daysAgo(4)),
    createdAt: _daysAgo(5),
  ),
  LeaderboardEntry(
    id: 'e-11',
    gameId: 'g-3',
    userId: 'u-3',
    score: 1100,
    status: Rejected('Results are outside of the range', _daysAgo(2)),
    createdAt: _daysAgo(2),
  ),
  LeaderboardEntry(
    id: 'e-12',
    gameId: 'g-3',
    userId: 'u-5',
    score: 700,
    status: Archived('You archived this', _daysAgo(8)),
    createdAt: _daysAgo(10),
  ),
];

String getUsername(String userId) {
  final user = fakeUsers.firstWhere(
        (u) => u.id == userId,
    orElse: () => User(id: userId, username: 'Unknown player', role: Role.guest),
  );
  return user.username;
}