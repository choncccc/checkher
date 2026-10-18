class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.address,
    this.lastPeriodStart,
    this.cycleLength = 28,
    this.periodLength = 5,
  });

  final int id;
  final String username;
  final String displayName;
  final String address;
  final DateTime? lastPeriodStart;
  final int cycleLength;
  final int periodLength;

  factory AppUser.fromRow(Map<String, Object?> row) => AppUser(
    id: row['id'] as int,
    username: row['username'] as String,
    displayName: row['display_name'] as String,
    address: row['address'] as String,
    lastPeriodStart: row['last_period_start'] == null
        ? null
        : DateTime.parse(row['last_period_start'] as String),
    cycleLength: row['cycle_length'] as int,
    periodLength: row['period_length'] as int,
  );

  int? cycleDayOn(DateTime date) {
    final start = lastPeriodStart;
    if (start == null) return null;
    final today = DateTime(date.year, date.month, date.day);
    final s = DateTime(start.year, start.month, start.day);
    final diff = today.difference(s).inDays;
    if (diff < 0) return null;
    return diff % cycleLength + 1;
  }

  bool isOnPeriodOn(DateTime date) {
    final day = cycleDayOn(date);
    return day != null && day <= periodLength;
  }
}
