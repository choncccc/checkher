import 'package:intl/intl.dart';

import 'app_database.dart';

class Reminder {
  const Reminder({required this.id, required this.title, required this.done});
  final int id;
  final String title;
  final bool done;
}

/// Daily reminders. Each reminder can be ticked off once per calendar day.
class ReminderRepository {
  ReminderRepository(this._database);

  final AppDatabase _database;

  static String _day(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<List<Reminder>> forDay(int userId, DateTime day) async {
    final rows = await _database.db.rawQuery(
      '''
      SELECT r.id, r.title, c.reminder_id IS NOT NULL AS done
      FROM reminders r
      LEFT JOIN reminder_checks c ON c.reminder_id = r.id AND c.day = ?
      WHERE r.user_id = ?
      ORDER BY r.sort_order
      ''',
      [_day(day), userId],
    );
    return [
      for (final r in rows)
        Reminder(
          id: r['id'] as int,
          title: r['title'] as String,
          done: (r['done'] as int) == 1,
        ),
    ];
  }

  Future<void> setDone(int reminderId, DateTime day, bool done) async {
    if (done) {
      await _database.db.rawInsert(
        'INSERT OR IGNORE INTO reminder_checks (reminder_id, day) VALUES (?, ?)',
        [reminderId, _day(day)],
      );
    } else {
      await _database.db.delete(
        'reminder_checks',
        where: 'reminder_id = ? AND day = ?',
        whereArgs: [reminderId, _day(day)],
      );
    }
  }
}
