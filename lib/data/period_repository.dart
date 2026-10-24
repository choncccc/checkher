import 'package:intl/intl.dart';

import 'app_database.dart';

/// How heavy a logged bleeding day was (page 19 legend).
enum BleedingFlow {
  light('Light'),
  moderate('Moderate'),
  heavy('Heavy');

  const BleedingFlow(this.label);
  final String label;

  /// Next heaviness when a logged day is double-tapped.
  BleedingFlow get next => values[(index + 1) % values.length];
}

/// Bleeding days logged on the Menstrual Cycle Calendar.
class PeriodRepository {
  PeriodRepository(this._database);

  final AppDatabase _database;

  static final _format = DateFormat('yyyy-MM-dd');
  static String _day(DateTime d) => _format.format(d);

  /// Logged days from [from] to [to], both inclusive, keyed by date.
  Future<Map<DateTime, BleedingFlow>> forRange(
    int userId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _database.db.query(
      'period_days',
      columns: ['day', 'flow'],
      where: 'user_id = ? AND day BETWEEN ? AND ?',
      whereArgs: [userId, _day(from), _day(to)],
    );
    return {
      for (final r in rows)
        _format.parse(r['day'] as String): BleedingFlow.values.byName(
          r['flow'] as String,
        ),
    };
  }

  /// Logs [day] with [flow], or clears it when [flow] is null.
  Future<void> setFlow(int userId, DateTime day, BleedingFlow? flow) async {
    if (flow == null) {
      await _database.db.delete(
        'period_days',
        where: 'user_id = ? AND day = ?',
        whereArgs: [userId, _day(day)],
      );
    } else {
      await _database.db.rawInsert(
        'INSERT OR REPLACE INTO period_days (user_id, day, flow) '
        'VALUES (?, ?, ?)',
        [userId, _day(day), flow.name],
      );
    }
  }

  /// Clears the logged days from [from] to [to], both inclusive, and returns
  /// what was cleared so it can be restored.
  Future<Map<DateTime, BleedingFlow>> clearRange(
    int userId,
    DateTime from,
    DateTime to,
  ) async {
    final cleared = await forRange(userId, from, to);
    await _database.db.delete(
      'period_days',
      where: 'user_id = ? AND day BETWEEN ? AND ?',
      whereArgs: [userId, _day(from), _day(to)],
    );
    return cleared;
  }

  /// First day of the most recent run of consecutive logged days, or null
  /// if nothing is logged.
  Future<DateTime?> latestPeriodStart(int userId) async {
    final rows = await _database.db.query(
      'period_days',
      columns: ['day'],
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'day DESC',
    );
    DateTime? start;
    for (final r in rows) {
      // Parsed as UTC so a daylight-saving change can't shorten a day.
      final d = _format.parseUtc(r['day'] as String);
      if (start != null && start.difference(d).inDays > 1) break;
      start = d;
    }
    return start == null ? null : DateTime(start.year, start.month, start.day);
  }
}
