import 'package:flutter/widgets.dart';

import 'assessment_repository.dart';
import 'auth_repository.dart';
import 'reminder_repository.dart';

/// Makes the repositories available to every screen.
class Services extends InheritedWidget {
  const Services({
    super.key,
    required this.auth,
    required this.reminders,
    required this.assessments,
    required super.child,
  });

  final AuthRepository auth;
  final ReminderRepository reminders;
  final AssessmentRepository assessments;

  static Services of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Services>()!;

  @override
  bool updateShouldNotify(Services oldWidget) =>
      auth != oldWidget.auth ||
      reminders != oldWidget.reminders ||
      assessments != oldWidget.assessments;
}
