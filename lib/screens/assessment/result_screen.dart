import 'package:flutter/material.dart';

import '../../content/assessment.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';
import '../placeholder_screen.dart';
import 'assessment_widgets.dart';

/// Page 16: the four risk levels, with the user's result highlighted.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.level, this.onContinue});

  final RiskLevel level;

  /// Set during onboarding, where the result leads on into the app instead
  /// of back to the questionnaire.
  final VoidCallback? onContinue;

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
            onBack: onContinue == null
                ? () => Navigator.of(context).pop()
                : null,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.aqua,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                children: [
                  for (final l in RiskLevel.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _LevelCard(level: l, isResult: l == level),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: AssessmentNote(fontSize: 11.5),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: WhitePillButton(
                      label: 'Nearby Health Services',
                      fontSize: 19,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            body: PlaceholderScreen(
                              title: 'Nearby Health Services',
                              onBack: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (onContinue != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FilledButton(
                        onPressed: onContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Continue to CheckHER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.isResult});

  final RiskLevel level;
  final bool isResult;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isResult ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: isResult
              ? Border.all(color: AppColors.ink, width: 2.5)
              : null,
        ),
        child: Column(
          children: [
            if (isResult)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'YOUR RESULT',
                  style: TextStyle(
                    color: AppColors.aqua,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            Text(level.title, style: displayStyle.copyWith(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              level.description,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
