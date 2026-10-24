import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'data/assessment_repository.dart';
import 'data/auth_repository.dart';
import 'data/period_repository.dart';
import 'data/reminder_repository.dart';
import 'data/services.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await AppDatabase.open();
  runApp(
    Services(
      auth: AuthRepository(db),
      reminders: ReminderRepository(db),
      assessments: AssessmentRepository(db),
      periods: PeriodRepository(db),
      child: const CheckHerApp(),
    ),
  );
}

class CheckHerApp extends StatelessWidget {
  const CheckHerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckHER',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // The layouts are designed for phones; keep phone proportions on
      // tablets by centering a fixed-width column.
      builder: (context, child) => ColoredBox(
        color: AppColors.mint,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
