import 'package:flutter/widgets.dart';

import 'assessment_repository.dart';
import 'auth_repository.dart';
import 'meal_repository.dart';
import 'medication_repository.dart';
import 'period_repository.dart';
import 'reminder_repository.dart';

/// Makes the repositories available to every screen.
class Services extends InheritedWidget {
  const Services({
    super.key,
    required this.auth,
    required this.reminders,
    required this.assessments,
    required this.periods,
    required this.medications,
    required this.meals,
    required super.child,
  });

  final AuthRepository auth;
  final ReminderRepository reminders;
  final AssessmentRepository assessments;
  final PeriodRepository periods;
  final MedicationRepository medications;
  final MealRepository meals;

  static Services of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Services>()!;

  @override
  bool updateShouldNotify(Services oldWidget) =>
      auth != oldWidget.auth ||
      reminders != oldWidget.reminders ||
      assessments != oldWidget.assessments ||
      periods != oldWidget.periods ||
      medications != oldWidget.medications ||
      meals != oldWidget.meals;
}
