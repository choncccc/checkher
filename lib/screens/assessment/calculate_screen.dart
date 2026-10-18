import 'package:flutter/material.dart';

import '../../content/assessment.dart';
import '../../data/services.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';
import 'assessment_widgets.dart';
import 'result_screen.dart';

/// Page 15: "Calculate the result" step after the questionnaire.
class CalculateScreen extends StatelessWidget {
  const CalculateScreen({
    super.key,
    required this.userId,
    required this.answers,
  });

  final int userId;
  final List<Answer> answers;

  Future<void> _calculate(BuildContext context) async {
    final nav = Navigator.of(context);
    final level = await Services.of(context).assessments.save(userId, answers);
    // Drop the questionnaire too: once taken, the Menu shows the result.
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ResultScreen(level: level)),
      (r) => r.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const LogoHeader(),
          const SizedBox(height: 12),
          AssessmentTitle(
            title: 'PMOS RISK\nASSESSMENT',
            subtitle: 'EMERGENCY SIGNS',
            onBack: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.aqua,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                children: [
                  Center(
                    child: WhitePillButton(
                      label: 'Calculate the result',
                      fontSize: 20,
                      onPressed: () => _calculate(context),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const AssessmentNote(fontSize: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
