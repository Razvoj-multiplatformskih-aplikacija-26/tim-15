sealed class EntryStatus {
  const EntryStatus();
}

final class Pending extends EntryStatus {
  const Pending();
}

final class Approved extends EntryStatus {
  final DateTime approvedAt;
  const Approved(this.approvedAt);
}

final class Rejected extends EntryStatus {
  final String reason;
  final DateTime rejectedAt;
  const Rejected(this.reason, this.rejectedAt);
}

final class Archived extends EntryStatus {
  final String reason;
  final DateTime archivedAt;
  const Archived(this.reason, this.archivedAt);
}

class LeaderboardEntry {
  final String id;
  final String gameId;
  final String userId;
  final num score;
  final EntryStatus status;
  final DateTime createdAt;

  const LeaderboardEntry({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.score,
    required this.status,
    required this.createdAt,
  });
}