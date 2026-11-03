import 'app_database.dart';
import 'medication_alerts.dart';

/// A daily dose on the Supplement Reminder schedule (page 20).
class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.note,
    required this.minutes,
    required this.enabled,
  });

  final int id;
  final String name; // e.g. "Metformin 300 mg"
  final String note; // e.g. "After Breakfast"; may be empty
  final int minutes; // time of day, as minutes after midnight
  final bool enabled;

  int get hour => minutes ~/ 60;
  int get minute => minutes % 60;
}

/// The doses due next: every enabled one sharing the soonest time, which is
/// tomorrow when today's have all passed. Null when none are enabled.
/// [meds] must be sorted by time, as [MedicationRepository.forUser] returns.
({List<Medication> doses, bool tomorrow})? nextDoses(
  List<Medication> meds,
  DateTime now,
) {
  final enabled = meds.where((m) => m.enabled).toList();
  if (enabled.isEmpty) return null;
  final nowMinutes = now.hour * 60 + now.minute;
  final later = enabled.where((m) => m.minutes > nowMinutes).toList();
  final tomorrow = later.isEmpty;
  final pool = tomorrow ? enabled : later;
  return (
    doses: pool.where((m) => m.minutes == pool.first.minutes).toList(),
    tomorrow: tomorrow,
  );
}

/// Saves the schedule and keeps the phone's notifications in step with it.
class MedicationRepository {
  MedicationRepository(this._database, this._alerts);

  final AppDatabase _database;
  final MedicationAlerts _alerts;

  Future<List<Medication>> forUser(int userId) async {
    final rows = await _database.db.query(
      'medications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'minutes, id',
    );
    return [
      for (final r in rows)
        Medication(
          id: r['id'] as int,
          name: r['name'] as String,
          note: r['note'] as String,
          minutes: r['minutes'] as int,
          enabled: (r['enabled'] as int) == 1,
        ),
    ];
  }

  Future<void> add(
    int userId, {
    required String name,
    required String note,
    required int minutes,
  }) async {
    await _database.db.insert('medications', {
      'user_id': userId,
      'name': name,
      'note': note,
      'minutes': minutes,
      'enabled': 1,
    });
    await syncAlerts(userId);
  }

  Future<void> update(
    int userId,
    int id, {
    required String name,
    required String note,
    required int minutes,
  }) async {
    await _database.db.update(
      'medications',
      {'name': name, 'note': note, 'minutes': minutes},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    await syncAlerts(userId);
  }

  Future<void> setEnabled(int userId, int id, bool enabled) async {
    await _database.db.update(
      'medications',
      {'enabled': enabled ? 1 : 0},
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    await syncAlerts(userId);
  }

  Future<void> delete(int userId, int id) async {
    await _database.db.delete(
      'medications',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    await syncAlerts(userId);
  }

  /// Makes the scheduled notifications match this user's schedule.
  Future<void> syncAlerts(int userId) async =>
      _alerts.sync(await forUser(userId));

  /// Asks to show notifications if needed; false when the user said no.
  Future<bool> requestAlertPermission() => _alerts.requestPermission();

  /// Stops all reminders, e.g. on logout so they don't fire for the next user.
  Future<void> cancelAlerts() => _alerts.cancelAll();
}
