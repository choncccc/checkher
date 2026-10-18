import '../content/assessment.dart';
import 'app_database.dart';

/// Stores PMOS Risk Assessment results per user.
class AssessmentRepository {
  AssessmentRepository(this._database);

  final AppDatabase _database;

  /// Scores [answers], saves the result for [userId] and returns its level.
  Future<RiskLevel> save(int userId, List<Answer> answers) async {
    final score = averageScore(answers);
    final level = riskForScore(score);
    await _database.db.insert('assessments', {
      'user_id': userId,
      'score': score,
      'level': level.name,
      'taken_at': DateTime.now().toIso8601String(),
    });
    return level;
  }

  /// The user's most recent result, or null if they haven't taken it yet.
  Future<RiskLevel?> latest(int userId) async {
    final rows = await _database.db.query(
      'assessments',
      columns: ['level'],
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RiskLevel.values.byName(rows.first['level'] as String);
  }
}
