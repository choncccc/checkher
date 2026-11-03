import 'package:flutter/material.dart';

import '../../content/care_topics.dart';
import '../../content/meal_guide.dart';
import '../../theme.dart';
import '../../widgets/menu_page_header.dart';

/// Coloured nutrition label, e.g. "High fiber".
class MealTagChip extends StatelessWidget {
  const MealTagChip({super.key, required this.tag});

  final MealTag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tag.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tag.label,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// A Meal Guide topic or recommended meal.
class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({
    super.key,
    required this.title,
    required this.blocks,
    this.tags = const [],
  });

  final String title;
  final List<CareBlock> blocks;
  final List<MealTag> tags;

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(fontSize: 14.5, height: 1.5);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MenuPageHeader(title: title.toUpperCase()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                if (tags.isNotEmpty) ...[
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: [for (final t in tags) MealTagChip(tag: t)],
                  ),
                  const SizedBox(height: 16),
                ],
                if (blocks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      'Content coming soon',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                for (final b in blocks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      b.bullet ? '•  ${b.text}' : b.text,
                      style: b.bold
                          ? body.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepTeal,
                            )
                          : body,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
