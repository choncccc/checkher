import 'package:checkher/content/foods.dart';
import 'package:checkher/data/app_database.dart';
import 'package:checkher/data/assessment_repository.dart';
import 'package:checkher/data/auth_repository.dart';
import 'package:checkher/data/meal_repository.dart';
import 'package:checkher/data/medication_alerts.dart';
import 'package:checkher/data/medication_repository.dart';
import 'package:checkher/data/period_repository.dart';
import 'package:checkher/data/reminder_repository.dart';
import 'package:checkher/data/services.dart';
import 'package:checkher/models/user.dart';
import 'package:checkher/screens/assessment/assessment_widgets.dart';
import 'package:checkher/screens/main_shell.dart';
import 'package:checkher/screens/services/nearby_services_screen.dart';
import 'package:checkher/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late _FakeAlerts alerts;
  setUp(() => alerts = _FakeAlerts());

  // Database calls finish on a real isolate, so let real time pass as well as
  // pumping frames. pumpAndSettle would never return with spinners on screen.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final target = find.text(text).first;
    await tester.ensureVisible(target);
    await tester.pump();
    await tester.tap(target);
    await settle(tester);
  }

  Future<AppDatabase> openApp(WidgetTester tester) async {
    // Tall enough that the lazily built questionnaire is all on screen, and
    // wide because the test font's square glyphs overflow a phone-width row.
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = (await tester.runAsync(
      () => AppDatabase.open(
        factory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      ),
    ))!;
    // Runs even when a test fails, so the shared in-memory database is fresh
    // for the next one.
    addTearDown(() => tester.runAsync(db.close));
    final auth = AuthRepository(db);
    final AppUser user = (await tester.runAsync(
      () => auth.signUp(
        username: 'geraldine',
        displayName: 'Geraldine',
        password: 'secret123',
        address: 'Agoo, La Union',
      ),
    ))!;
    await tester.pumpWidget(
      Services(
        auth: auth,
        reminders: ReminderRepository(db),
        assessments: AssessmentRepository(db),
        periods: PeriodRepository(db),
        medications: MedicationRepository(db, alerts),
        meals: MealRepository(db),
        child: MaterialApp(theme: buildTheme(), home: MainShell(user: user)),
      ),
    );
    await settle(tester);
    return db;
  }

  Future<void> finish(WidgetTester tester, AppDatabase db) async {
    // Disposes Home's clock timer, which would otherwise fail the test.
    await tester.pumpWidget(const SizedBox());
  }

  Future<void> answerAndCalculate(WidgetTester tester) async {
    for (var q = 0; q < 6; q++) {
      // Each card has Yes, No and Unsure; answer "No".
      await tester.tap(find.widgetWithText(AnswerChip, 'No').at(q));
      await tester.pump();
    }
    await tapText(tester, 'Next');
    await tapText(tester, 'Calculate the result');
  }

  testWidgets('leaving a new result returns to the tab it was opened from', (
    tester,
  ) async {
    final db = await openApp(tester);
    await tapText(tester, 'Menu');
    await tapText(tester, 'PMOS Risk Assessment');
    await answerAndCalculate(tester);
    expect(find.text('YOUR RESULT'), findsOneWidget);

    await tester.tap(find.byType(RoundBackButton));
    await settle(tester);

    expect(find.textContaining('Geraldine!'), findsOneWidget);
    await finish(tester, db);
  });

  testWidgets('the result links to the real Nearby Health Services page', (
    tester,
  ) async {
    final db = await openApp(tester);
    await tapText(tester, 'Menu');
    await tapText(tester, 'PMOS Risk Assessment');
    await answerAndCalculate(tester);

    await tapText(tester, 'Nearby Health Services');

    expect(find.byType(NearbyServicesScreen), findsOneWidget);
    await finish(tester, db);
  });

  testWidgets('the assessment can be retaken, and backing out keeps the result', (
    tester,
  ) async {
    final db = await openApp(tester);
    await tapText(tester, 'Menu');
    await tapText(tester, 'PMOS Risk Assessment');
    await answerAndCalculate(tester);

    await tapText(tester, 'Retake Assessment');
    expect(find.byType(AnswerChip), findsWidgets);

    await tester.tap(find.byType(RoundBackButton).last);
    await settle(tester);
    expect(find.text('YOUR RESULT'), findsOneWidget);

    await tapText(tester, 'Retake Assessment');
    await answerAndCalculate(tester);
    expect(find.text('YOUR RESULT'), findsOneWidget);

    await tester.tap(find.byType(RoundBackButton));
    await settle(tester);
    expect(find.textContaining('Geraldine!'), findsOneWidget);
    await finish(tester, db);
  });

  testWidgets('a medication added from the Menu is scheduled and shown next', (
    tester,
  ) async {
    final db = await openApp(tester);
    await tapText(tester, 'Menu');
    await tapText(tester, 'Supplement Reminder');
    expect(find.text('None set'), findsOneWidget);

    await tapText(tester, '+ Add Medication');
    await tester.enterText(find.byType(TextFormField).at(0), 'Metformin 300 mg');
    await tester.enterText(find.byType(TextFormField).at(1), 'After Breakfast');
    await tapText(tester, 'Save');

    expect(find.text('Metformin 300 mg'), findsWidgets);
    expect(find.text('After Breakfast'), findsOneWidget);
    expect(alerts.scheduled.map((m) => m.name), ['Metformin 300 mg']);
    expect(alerts.permissionRequests, 1);

    await tester.tap(find.byType(Switch));
    await settle(tester);
    expect(alerts.scheduled, isEmpty);
    await finish(tester, db);
  });

  testWidgets('saving a medication needs a name', (tester) async {
    final db = await openApp(tester);
    await tapText(tester, 'Menu');
    await tapText(tester, 'Supplement Reminder');
    await tapText(tester, '+ Add Medication');
    await tapText(tester, 'Save');

    expect(find.text('Enter the name of the medication'), findsOneWidget);
    expect(alerts.scheduled, isEmpty);
    await finish(tester, db);
  });

  testWidgets('a denied notification permission is explained', (tester) async {
    alerts.grant = false;
    final db = await openApp(tester);
    await tapText(tester, 'Menu');
    await tapText(tester, 'Supplement Reminder');
    await tapText(tester, '+ Add Medication');
    await tester.enterText(find.byType(TextFormField).at(0), 'Metformin 300 mg');
    await tapText(tester, 'Save');

    expect(find.textContaining('Notifications are off'), findsOneWidget);
    await finish(tester, db);
  });

  testWidgets('Meal Guide counters change and survive reopening', (
    tester,
  ) async {
    final db = await openApp(tester);
    await tapText(tester, 'Menu');
    await tapText(tester, 'Meal Guide');
    expect(find.text('1600'), findsOneWidget);
    expect(find.text('MEAL OPTION 6'), findsOneWidget);

    await tester.tap(find.byTooltip('One glass more'));
    await tester.pump();
    await tester.tap(find.byTooltip('One glass more'));
    await tester.tap(find.byTooltip('Raise calorie goal'));
    await settle(tester);
    expect(find.text('1650'), findsOneWidget);

    await tester.tap(find.byType(RoundBackButton));
    await settle(tester);
    await tapText(tester, 'Menu');
    await tapText(tester, 'Meal Guide');
    expect(find.text('1650'), findsOneWidget);
    expect(find.text('2/9', findRichText: true), findsOneWidget);
    await finish(tester, db);
  });

  _foodGuideContentTests();

  testWidgets('foods can be filtered, and warnings show without opening', (
    tester,
  ) async {
    final db = await openApp(tester);
    await tapText(tester, 'Menu');
    await tapText(tester, 'Meal Guide');
    await tapText(tester, 'PMOS friendly foods');
    expect(find.text('Avocado'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'star');
    await settle(tester);
    expect(find.text('Avocado'), findsNothing);
    expect(find.text('Star Fruit (Carambola)'), findsOneWidget);
    expect(find.textContaining('kidney'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tapText(tester, 'Protein');
    expect(find.text('Salmon'), findsOneWidget);
    expect(find.text('Avocado'), findsNothing);

    await tapText(tester, 'Salmon');
    expect(find.text('Why it helps'), findsOneWidget);
    expect(find.text('Omega-3: 1.8g'), findsOneWidget);
    await finish(tester, db);
  });

  testWidgets('Meal Guide topics open with placeholder content', (tester) async {
    final db = await openApp(tester);
    await tapText(tester, 'Menu');
    await tapText(tester, 'Meal Guide');
    await tapText(tester, 'Food to avoid');

    expect(find.text('FOOD TO AVOID'), findsOneWidget);
    expect(find.text('Content coming soon'), findsOneWidget);
    await finish(tester, db);
  });
}

void _foodGuideContentTests() {
  test('the food guide has every food from the content document', () {
    int count(FoodCategory c) => foods.where((f) => f.category == c).length;
    expect(count(FoodCategory.fruits), 21);
    expect(count(FoodCategory.vegetables), 18);
    expect(count(FoodCategory.dairy), 11);
    expect(count(FoodCategory.protein), 14);
    expect(count(FoodCategory.oilsAndFats), 14);
    expect(foods.map((f) => f.name).toSet(), hasLength(foods.length));
  });

  test('food entries contain no leftover notes meant for developers', () {
    for (final f in foods) {
      final all = '${f.name} ${f.serving} ${f.nutrients} ${f.benefit}';
      expect(all, isNot(matches(RegExp(
        'Implementation|SAFETY FLAG|app profile|in database|PCOS|Serving:',
      ))), reason: f.name);
      expect(f.nutrition.first.$1, 'Energy', reason: f.name);
    }
  });

  test('foods with safety concerns carry a visible warning', () {
    Food named(String n) => foods.firstWhere((f) => f.name.startsWith(n));
    expect(named('Star Fruit').warning, contains('kidney'));
    expect(named('Pomelo').warning, contains('medicines'));
    expect(foods.where((f) => f.warning != null), hasLength(2));
  });
}

class _FakeAlerts implements MedicationAlerts {
  List<Medication> scheduled = [];
  int permissionRequests = 0;
  bool grant = true;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> sync(List<Medication> medications) async =>
      scheduled = medications.where((m) => m.enabled).toList();

  @override
  Future<void> cancelAll() async => scheduled = [];
}
