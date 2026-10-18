import 'package:flutter/material.dart';

import '../../content/assessment.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';
import '../../widgets/seal_badge.dart';
import 'assessment_widgets.dart';
import 'calculate_screen.dart';

/// Page 14: the full self-screening questionnaire, opened from the Menu.
class AssessmentFormScreen extends StatefulWidget {
  const AssessmentFormScreen({super.key, required this.userId});

  final int userId;

  @override
  State<AssessmentFormScreen> createState() => _AssessmentFormScreenState();
}

class _AssessmentFormScreenState extends State<AssessmentFormScreen> {
  final _answers = List<Answer?>.filled(assessmentQuestions.length, null);

  void _next() {
    if (_answers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all the questions.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CalculateScreen(
          userId: widget.userId,
          answers: _answers.cast<Answer>(),
        ),
      ),
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
            title: 'PMOS RISK ASSESSMENT',
            subtitle: 'Self - Screening Questionnaire',
            titleSize: 24,
            onBack: () => Navigator.of(context).pop(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: AssessmentNote(fontSize: 9.5),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: AppColors.aqua,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  children: [
                    for (var i = 0; i < assessmentQuestions.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _QuestionCard(
                          question: assessmentQuestions[i],
                          answer: _answers[i],
                          onAnswer: (a) => setState(() => _answers[i] = a),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: WhitePillButton(label: 'Next', onPressed: _next),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  final AssessmentQuestion question;
  final Answer? answer;
  final ValueChanged<Answer> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          SealBadge(icon: question.icon, size: 54),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    question.title,
                    textAlign: TextAlign.center,
                    style: displayStyle.copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final a in Answer.values)
                      AnswerChip(
                        answer: a,
                        selected: a == answer,
                        onTap: () => onAnswer(a),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            answer == null ? Icons.arrow_forward : Icons.check_circle,
            size: 30,
            color: answer == null ? AppColors.ink : AppColors.deepTeal,
          ),
        ],
      ),
    );
  }
}
