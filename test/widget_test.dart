import 'package:checkher/content/assessment.dart';
import 'package:checkher/data/app_database.dart';
import 'package:checkher/data/assessment_repository.dart';
import 'package:checkher/data/auth_repository.dart';
import 'package:checkher/data/period_repository.dart';
import 'package:checkher/data/reminder_repository.dart';
import 'package:checkher/models/user.dart';
import 'package:checkher/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase db;
  late AuthRepository auth;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await AppDatabase.open(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    auth = AuthRepository(db);
  });

  tearDown(() => db.close());

  Future<AppUser> signUp([String username = 'geraldine']) => auth.signUp(
        username: username,
        displayName: 'Geraldine',
        password: 'secret123',
        address: '12 Cases Blvd, Agoo, La Union',
      );

  test('sign up creates a session and default reminders', () async {
    final user = await signUp();
    expect((await auth.currentUser())?.id, user.id);
    final reminders = await ReminderRepository(db).forDay(user.id, DateTime.now());
    expect(reminders.map((r) => r.title), AppDatabase.defaultReminders);
  });

  test('usernames are unique, case-insensitively', () async {
    await signUp();
    expect(() => signUp('GERALDINE'), throwsA(isA<AuthException>()));
  });

  test('login checks the password and logout clears the session', () async {
    await signUp();
    await auth.logout();
    expect(await auth.currentUser(), isNull);
    expect(() => auth.login('geraldine', 'wrong'), throwsA(isA<AuthException>()));
    final user = await auth.login('Geraldine', 'secret123');
    expect(user.displayName, 'Geraldine');
    expect((await auth.currentUser())?.id, user.id);
  });

  test('password reset requires the matching address', () async {
    await signUp();
    expect(
      () => auth.resetPassword(
        username: 'geraldine',
        address: 'somewhere else',
        newPassword: 'newpass1',
      ),
      throwsA(isA<AuthException>()),
    );
    // Case, commas and extra spaces are ignored.
    await auth.resetPassword(
      username: 'geraldine',
      address: '12 cases blvd  agoo la union',
      newPassword: 'newpass1',
    );
    await auth.login('geraldine', 'newpass1');
  });

  test('reminder checks are stored per day', () async {
    final user = await signUp();
    final repo = ReminderRepository(db);
    final today = DateTime(2026, 8, 19);
    final first = (await repo.forDay(user.id, today)).first;
    await repo.setDone(first.id, today, true);
    expect((await repo.forDay(user.id, today)).first.done, isTrue);
    expect(
      (await repo.forDay(user.id, today.add(const Duration(days: 1)))).first.done,
      isFalse,
    );
  });

  test('greeting follows the time of day', () {
    String at(int hour) => greetingFor(DateTime(2026, 10, 14, hour));
    expect(at(8), 'Good Morning');
    expect(at(12), 'Good Afternoon');
    expect(at(17), 'Good Afternoon');
    expect(at(18), 'Good Evening');
    expect(at(23), 'Good Evening');
    expect(at(0), 'Good Evening');
    expect(at(5), 'Good Morning');
  });

  test('cycle day wraps around the cycle length', () {
    final user = AppUser(
      id: 1,
      username: 'g',
      displayName: 'G',
      address: 'x',
      lastPeriodStart: DateTime(2026, 8, 17),
    );
    expect(user.cycleDayOn(DateTime(2026, 8, 19)), 3);
    expect(user.isOnPeriodOn(DateTime(2026, 8, 19)), isTrue);
    expect(user.cycleDayOn(DateTime(2026, 9, 14)), 1);
    expect(user.isOnPeriodOn(DateTime(2026, 8, 25)), isFalse);
  });

  test('risk level is the average of the answers', () {
    List<Answer> answers(int yes, int unsure) => [
          for (var i = 0; i < 6; i++)
            i < yes ? Answer.yes : (i < yes + unsure ? Answer.unsure : Answer.no),
        ];
    expect(computeRisk(answers(0, 0)), RiskLevel.low);
    expect(computeRisk(answers(1, 0)), RiskLevel.low); // 0.17
    expect(computeRisk(answers(1, 1)), RiskLevel.mild); // 0.25
    expect(computeRisk(answers(3, 0)), RiskLevel.moderate); // 0.5
    expect(computeRisk(answers(4, 1)), RiskLevel.high); // 0.75
    expect(computeRisk(answers(0, 6)), RiskLevel.moderate); // all unsure
  });

  test('the latest assessment result is kept per user', () async {
    final user = await signUp();
    final repo = AssessmentRepository(db);
    expect(await repo.latest(user.id), isNull);
    await repo.save(user.id, List.filled(6, Answer.no));
    expect(await repo.latest(user.id), RiskLevel.low);
    await repo.save(user.id, List.filled(6, Answer.yes));
    expect(await repo.latest(user.id), RiskLevel.high);
  });

  test('logged bleeding days are stored per user with their flow', () async {
    final user = await signUp();
    final repo = PeriodRepository(db);
    await repo.setFlow(user.id, DateTime(2026, 7, 6), BleedingFlow.light);
    await repo.setFlow(user.id, DateTime(2026, 7, 7), BleedingFlow.light);
    await repo.setFlow(user.id, DateTime(2026, 7, 7), BleedingFlow.heavy);
    await repo.setFlow(user.id, DateTime(2026, 8, 1), BleedingFlow.moderate);
    expect(await repo.forRange(user.id, DateTime(2026, 7), DateTime(2026, 7, 31)), {
      DateTime(2026, 7, 6): BleedingFlow.light,
      DateTime(2026, 7, 7): BleedingFlow.heavy,
    });
    await repo.setFlow(user.id, DateTime(2026, 7, 6), null);
    expect(
      (await repo.forRange(user.id, DateTime(2026), DateTime(2026, 12, 31))).keys,
      [DateTime(2026, 7, 7), DateTime(2026, 8, 1)],
    );
    expect(BleedingFlow.heavy.next, BleedingFlow.light);
  });

  test('period start is the first day of the latest logged run', () async {
    final user = await signUp();
    final repo = PeriodRepository(db);
    expect(await repo.latestPeriodStart(user.id), isNull);
    for (final d in [6, 7, 8, 9, 10, 11, 12]) {
      await repo.setFlow(user.id, DateTime(2026, 7, d), BleedingFlow.moderate);
    }
    expect(await repo.latestPeriodStart(user.id), DateTime(2026, 7, 6));
    for (final d in [3, 4, 5]) {
      await repo.setFlow(user.id, DateTime(2026, 8, d), BleedingFlow.light);
    }
    expect(await repo.latestPeriodStart(user.id), DateTime(2026, 8, 3));
  });

  test('clearing a range returns what was cleared', () async {
    final user = await signUp();
    final repo = PeriodRepository(db);
    for (final d in [12, 14, 15, 20]) {
      await repo.setFlow(user.id, DateTime(2026, 10, d), BleedingFlow.moderate);
    }
    final cleared =
        await repo.clearRange(user.id, DateTime(2026, 10, 13), DateTime(2026, 10, 18));
    expect(cleared.keys, [DateTime(2026, 10, 14), DateTime(2026, 10, 15)]);
    expect(
      (await repo.forRange(user.id, DateTime(2026, 10), DateTime(2026, 10, 31))).keys,
      [DateTime(2026, 10, 12), DateTime(2026, 10, 20)],
    );
  });
}
