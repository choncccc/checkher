import 'package:flutter/material.dart';

/// PMOS Risk Assessment questions and scoring (pages 14–16).
class AssessmentQuestion {
  const AssessmentQuestion({
    required this.title,
    required this.question,
    required this.icon,
  });
  final String title;
  final String question;
  final IconData icon; // TODO: swap for the illustrated badge icons
}

const assessmentQuestions = <AssessmentQuestion>[
  AssessmentQuestion(
    title: 'Irregular Menstruation',
    question: 'Are your periods irregular or frequently missed?',
    icon: Icons.calendar_month_outlined,
  ),
  AssessmentQuestion(
    title: 'Acne & Skin Health',
    question: 'Did you experience persistent acne or skin changes?',
    icon: Icons.face_retouching_natural,
  ),
  AssessmentQuestion(
    title: 'Excessive Hair Growth',
    question:
        'Did you notice unwanted hair growth on your face, chest, or back?',
    icon: Icons.face_6_outlined,
  ),
  AssessmentQuestion(
    title: 'Weight Management',
    question:
        'Do you have persistent difficulty losing weight or recent, unexplained gain?',
    icon: Icons.monitor_weight_outlined,
  ),
  AssessmentQuestion(
    title: 'Hair Thinning',
    question: 'Have you noticed significant hair loss?',
    icon: Icons.face_3_outlined,
  ),
  AssessmentQuestion(
    title: 'Family History',
    question: 'Does a female relative have a diagnosed case of PMOS?',
    icon: Icons.family_restroom,
  ),
];

enum Answer {
  yes('Yes', 1, Color(0xFF00FFE1)),
  no('No', 0, Color(0xFFCB6CE6)),
  unsure('Unsure', 0.5, Color(0xFFE2A9F1));

  const Answer(this.label, this.score, this.color);
  final String label;
  final double score;
  final Color color;
}

enum RiskLevel {
  low(
    'Low Risk',
    'The respondent reports few or no symptoms and risk factors associated '
        'with hormonal and metabolic reproductive health concerns.',
  ),
  mild(
    'Mild Risk',
    'The respondent reports a limited number of symptoms and risk factors '
        'that may indicate emerging hormonal or metabolic reproductive health '
        'concerns.',
  ),
  moderate(
    'Moderate Risk',
    'The respondent reports multiple symptoms and risk factors associated '
        'with hormonal and metabolic reproductive health concerns, suggesting '
        'an increased likelihood of underlying reproductive health issues that '
        'warrant further clinical assessment.',
  ),
  high(
    'High Risk',
    'The respondent reports numerous symptoms and risk factors associated '
        'with hormonal and metabolic reproductive health concerns, indicating '
        'a greater likelihood of significant reproductive health issues.',
  );

  const RiskLevel(this.title, this.description);
  final String title;
  final String description;
}

/// Average of the answers: Yes 1, Unsure 0.5, No 0.
double averageScore(List<Answer> answers) {
  assert(answers.isNotEmpty);
  return answers.fold<double>(0, (sum, a) => sum + a.score) / answers.length;
}

/// TODO: Computation
/// Scoring: Yes = 1, Unsure = 0.5, No = 0, averaged
// - below 0.25 → Low
// - 0.25 to under 0.5 → Mild
// - 0.5 to under 0.75 → Moderate
// - 0.75 and up → High
RiskLevel riskForScore(double avg) {
  if (avg < 0.25) return RiskLevel.low;
  if (avg < 0.5) return RiskLevel.mild;
  if (avg < 0.75) return RiskLevel.moderate;
  return RiskLevel.high;
}

RiskLevel computeRisk(List<Answer> answers) =>
    riskForScore(averageScore(answers));

const assessmentNote =
    'The PMOS Health Assessment does not diagnose PMOS. It is intended only '
    'for risk identification and health awareness. A moderate- or high-risk '
    'result does not confirm PMOS; users are encouraged to consult a qualified '
    'healthcare professional for proper assessment and diagnosis.';
