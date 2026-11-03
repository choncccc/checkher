import 'package:flutter/material.dart';

import 'care_topics.dart';

/// Nutrition labels under the recommended meals (page 21).
enum MealTag {
  lowGi('low GI', Color(0xFFBFE8A8)),
  highFiber('High fiber', Color(0xFFA77BEA)),
  omega3('Omega 3', Color(0xFF9CD3F5)),
  protein('Protein', Color(0xFFFBE7A1)),
  antiInflammatory('Anti-Inflammatory', Color(0xFFBFE8A8)),
  antioxidant('Anti-oxidant', Color(0xFFBFE8A8)),
  healthyFats('Healthy-fats', Color(0xFFF7A8A8));

  const MealTag(this.label, this.color);
  final String label;
  final Color color;
}

/// A shortcut in the row under the counters. Empty [blocks] show as "coming
/// soon" until the content is added here.
class MealTopic {
  const MealTopic({
    required this.title,
    required this.icon,
    required this.color,
    this.blocks = const [],
    this.isFoodGuide = false,
  });

  final String title;
  final IconData icon; // TODO: swap for the illustrated badge icons
  final Color color;
  final List<CareBlock> blocks;

  /// Opens the searchable food list instead of an article.
  final bool isFoodGuide;
}

const mealTopics = <MealTopic>[
  MealTopic(
    title: 'PMOS friendly foods',
    icon: Icons.ramen_dining,
    color: Color(0xFF5CF0DD),
    isFoodGuide: true,
  ),
  MealTopic(
    title: 'low GI food',
    icon: Icons.eco,
    color: Color(0xFFBFE8A8),
  ),
  MealTopic(
    title: 'Food to avoid',
    icon: Icons.warning_rounded,
    color: Color(0xFFF2A0A0),
  ),
  MealTopic(
    title: 'Hydration Guide',
    icon: Icons.local_drink,
    color: Color(0xFFE2B5F0),
  ),
  MealTopic(
    title: 'Meal Planner',
    icon: Icons.edit_note,
    color: Color(0xFFC3A6F5),
  ),
];

/// A meal in the "Recommended for you" grid. Titles and details are
/// placeholders from the layout until the real meals are added here.
class MealOption {
  const MealOption({
    required this.title,
    required this.tags,
    this.blocks = const [],
  });

  final String title;
  final List<MealTag> tags;
  final List<CareBlock> blocks;
}

const mealOptions = <MealOption>[
  MealOption(
    title: 'MEAL OPTION 1',
    tags: [MealTag.lowGi, MealTag.highFiber],
  ),
  MealOption(
    title: 'MEAL OPTION 2',
    tags: [MealTag.omega3, MealTag.protein],
  ),
  MealOption(
    title: 'MEAL OPTION 3',
    tags: [MealTag.antiInflammatory],
  ),
  MealOption(
    title: 'MEAL OPTION 4',
    tags: [MealTag.highFiber, MealTag.antioxidant],
  ),
  MealOption(
    title: 'MEAL OPTION 5',
    tags: [MealTag.protein, MealTag.highFiber],
  ),
  MealOption(
    title: 'MEAL OPTION 6',
    tags: [MealTag.antioxidant, MealTag.healthyFats],
  ),
];

const mealGuideBanner =
    'Focus on whole foods, balanced meals, and staying active to help manage '
    'PMOS signs and symptoms';
