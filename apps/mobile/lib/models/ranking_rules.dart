enum RankingOrder {
  ascending,
  descending,
}

class LeaderboardRules {
  final String metricName;
  final RankingOrder rankingOrder;
  final num minimumValue;
  final num maximumValue;
  final int? participantLimit;

  const LeaderboardRules({
    required this.metricName,
    required this.rankingOrder,
    required this.minimumValue,
    required this.maximumValue,
    this.participantLimit,
  });
}