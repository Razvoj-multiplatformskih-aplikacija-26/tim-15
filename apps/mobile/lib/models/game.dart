import '../models/ranking_rules.dart';

class Game {
  final String id;
  final String name;
  final String description;
  final LeaderboardRules rules;

  const Game({
    required this.id,
    required this.name,
    required this.description,
    required this.rules,
  });
}