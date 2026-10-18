import 'package:flutter/material.dart';

import '../../content/assessment.dart';
import '../../theme.dart';

/// Black round back button from the assessment layouts.
class RoundBackButton extends StatelessWidget {
  const RoundBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

/// Title block under the logo, with an optional back button on the left.
class AssessmentTitle extends StatelessWidget {
  const AssessmentTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.titleSize = 28,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(top: onBack == null ? 0 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: displayStyle.copyWith(fontSize: titleSize),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          // Sits on the bottom edge of the logo header, as in the layout.
          if (onBack != null)
            Positioned(
              top: -26,
              left: 0,
              child: RoundBackButton(onPressed: onBack!),
            ),
        ],
      ),
    );
  }
}

/// The "Note: The PMOS Health Assessment does not diagnose…" disclaimer.
class AssessmentNote extends StatelessWidget {
  const AssessmentNote({super.key, this.fontSize = 11});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'Note: ',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: assessmentNote),
        ],
      ),
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: fontSize,
        fontStyle: FontStyle.italic,
        height: 1.4,
      ),
    );
  }
}

/// White pill button with serif label ("Next", "Calculate the result").
class WhitePillButton extends StatelessWidget {
  const WhitePillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize = 22,
  });

  final String label;
  final VoidCallback? onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: displayStyle.copyWith(fontSize: fontSize),
          ),
        ),
      ),
    );
  }
}

/// Yes / No / Unsure chip. The picked one gets a dark outline and a tick.
class AnswerChip extends StatelessWidget {
  const AnswerChip({
    super.key,
    required this.answer,
    required this.selected,
    required this.onTap,
    this.large = false,
  });

  final Answer answer;
  final bool selected;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: answer.color,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.ink : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: large ? 20 : 10,
            vertical: large ? 16 : 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                Icon(Icons.check, size: large ? 20 : 13),
                SizedBox(width: large ? 6 : 3),
              ],
              Text(
                answer.label,
                style: TextStyle(
                  fontSize: large ? 17 : 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
