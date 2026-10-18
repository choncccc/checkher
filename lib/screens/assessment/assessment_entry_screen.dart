import 'package:flutter/material.dart';

import '../../content/assessment.dart';
import '../../data/services.dart';
import 'assessment_form_screen.dart';
import 'result_screen.dart';

/// Menu → PMOS Risk Assessment: the saved result if the user has taken it
/// (during onboarding or before), otherwise the questionnaire.
class AssessmentEntryScreen extends StatefulWidget {
  const AssessmentEntryScreen({super.key, required this.userId});

  final int userId;

  @override
  State<AssessmentEntryScreen> createState() => _AssessmentEntryScreenState();
}

class _AssessmentEntryScreenState extends State<AssessmentEntryScreen> {
  late final Future<RiskLevel?> _latest;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _latest = Services.of(context).assessments.latest(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _latest,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final level = snap.data;
        return level == null
            ? AssessmentFormScreen(userId: widget.userId)
            : ResultScreen(level: level);
      },
    );
  }
}
