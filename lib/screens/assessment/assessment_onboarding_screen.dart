import 'package:flutter/material.dart';

import '../../content/assessment.dart';
import '../../data/services.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';
import '../../widgets/seal_badge.dart';
import 'assessment_widgets.dart';
import 'result_screen.dart';

/// Optional PMOS Risk Assessment shown right after sign-up: an intro, then
/// one page per question. Answering the last question goes straight to the
/// result (page 16). [onDone] runs on skip or after the result.
class AssessmentOnboardingScreen extends StatefulWidget {
  const AssessmentOnboardingScreen({
    super.key,
    required this.userId,
    required this.onDone,
  });

  final int userId;
  final VoidCallback onDone;

  @override
  State<AssessmentOnboardingScreen> createState() =>
      _AssessmentOnboardingScreenState();
}

class _AssessmentOnboardingScreenState
    extends State<AssessmentOnboardingScreen> {
  final _pages = PageController();
  final _answers = List<Answer?>.filled(assessmentQuestions.length, null);
  // 0 is the intro, 1..n are the questions.
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    setState(() => _page = page);
    _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _answer(int q, Answer a) async {
    if (_page != q + 1) return; // already moving on from this question
    setState(() => _answers[q] = a);
    // Short pause so the pick is visible before moving on.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    if (q + 1 < assessmentQuestions.length) {
      _goTo(q + 2);
      return;
    }
    final level = await Services.of(
      context,
    ).assessments.save(widget.userId, _answers.cast<Answer>());
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(level: level, onContinue: widget.onDone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = assessmentQuestions.length;
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(_page - 1);
      },
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              children: [
                const LogoHeader(),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: widget.onDone,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepTeal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_page > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    RoundBackButton(onPressed: () => _goTo(_page - 1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question $_page of $total',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.deepTeal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _page / total,
                              minHeight: 8,
                              color: AppColors.deepTeal,
                              backgroundColor: AppColors.aquaSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: PageView(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Intro(onStart: () => _goTo(1), onSkip: widget.onDone),
                  for (var i = 0; i < total; i++)
                    _QuestionPage(
                      question: assessmentQuestions[i],
                      answer: _answers[i],
                      onAnswer: (a) => _answer(i, a),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onStart, required this.onSkip});

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        const AssessmentTitle(
          title: 'PMOS RISK ASSESSMENT',
          subtitle: 'Self - Screening Questionnaire',
          titleSize: 26,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.aqua,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              Text(
                'Get to know your risk',
                textAlign: TextAlign.center,
                style: displayStyle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                'Answer ${assessmentQuestions.length} quick questions about '
                'your cycle and symptoms. It takes about a minute, and you '
                'can take it later from the Menu.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              WhitePillButton(label: 'Start', onPressed: onStart),
              const SizedBox(height: 4),
              TextButton(
                onPressed: onSkip,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const AssessmentNote(),
      ],
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  final AssessmentQuestion question;
  final Answer? answer;
  final ValueChanged<Answer> onAnswer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.aqua,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              children: [
                SealBadge(icon: question.icon, size: 88),
                const SizedBox(height: 14),
                Text(
                  question.title,
                  textAlign: TextAlign.center,
                  style: displayStyle.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 10),
                Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                for (final a in Answer.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: AnswerChip(
                        answer: a,
                        selected: a == answer,
                        large: true,
                        onTap: () => onAnswer(a),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
