import 'package:intl/intl.dart';

import 'app_database.dart';

/// The Meal Guide's counters for one day (page 21).
class MealDay {
  const MealDay({
    required this.water,
    required this.meals,
    required this.kcalGoal,
  });

  final int water;
  final int meals;
  final int kcalGoal;
}

class MealRepository {
  MealRepository(this._database);

  final AppDatabase _database;

  // Targets and the starting calorie goal, as shown in the layout.
  static const waterGoal = 9;
  static const mealGoal = 3;
  static const defaultKcalGoal = 1600;

  static String _day(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<MealDay> forDay(int userId, DateTime day) async {
    final db = _database.db;
    final counts = await db.query(
      'meal_days',
      where: 'user_id = ? AND day = ?',
      whereArgs: [userId, _day(day)],
    );
    final goal = await db.query(
      'meal_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return MealDay(
      water: counts.isEmpty ? 0 : counts.first['water'] as int,
      meals: counts.isEmpty ? 0 : counts.first['meals'] as int,
      kcalGoal: goal.isEmpty ? defaultKcalGoal : goal.first['kcal'] as int,
    );
  }

  Future<void> setWater(int userId, DateTime day, int glasses) =>
      _setCount(userId, day, 'water', glasses);

  Future<void> setMeals(int userId, DateTime day, int meals) =>
      _setCount(userId, day, 'meals', meals);

  /// [column] is one of the two names above, never user input. Older Android
  /// versions ship a SQLite without upsert, so insert the row, then update it.
  Future<void> _setCount(
    int userId,
    DateTime day,
    String column,
    int value,
  ) async {
    final db = _database.db;
    await db.rawInsert(
      'INSERT OR IGNORE INTO meal_days (user_id, day) VALUES (?, ?)',
      [userId, _day(day)],
    );
    await db.update(
      'meal_days',
      {column: value},
      where: 'user_id = ? AND day = ?',
      whereArgs: [userId, _day(day)],
    );
  }

  Future<void> setKcalGoal(int userId, int kcal) => _database.db.rawInsert(
    'INSERT OR REPLACE INTO meal_goals (user_id, kcal) VALUES (?, ?)',
    [userId, kcal],
  );
}
