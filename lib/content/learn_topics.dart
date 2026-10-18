import 'package:flutter/material.dart';

/// A PMOS Health Education entry on the Learn tab (page 12).
class LearnTopic {
  const LearnTopic({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final IconData icon; // TODO: swap for the illustrated badge icons
}

const learnTopics = <LearnTopic>[
  LearnTopic(
    title: 'What is PMOS?',
    subtitle: 'Understanding Polyendocrine Metabolic Ovarian Syndrome',
    icon: Icons.info_outline,
  ),
  LearnTopic(
    title: 'SIGNS & SYMPTOMS',
    subtitle: 'Irregular periods, hair growth, acne, etc.',
    icon: Icons.assignment_outlined,
  ),
  LearnTopic(
    title: 'CAUSES & RISK FACTORS',
    subtitle: 'Hormonal Imbalances, Genetics, Insulin Resistance',
    icon: Icons.female,
  ),
  LearnTopic(
    title: 'TREATMENT OPTIONS',
    subtitle: 'Medication, Hormone Therapy, and Procedures',
    icon: Icons.medication_outlined,
  ),
  LearnTopic(
    title: 'LIFESTYLE MANAGEMENT',
    subtitle: 'Diet, Exercise, Stress Reduction, Sleep',
    icon: Icons.self_improvement,
  ),
  LearnTopic(
    title: 'MYTHS VS FACTS',
    subtitle: 'Debunking Common Misconceptions',
    icon: Icons.psychology_alt_outlined,
  ),
];
