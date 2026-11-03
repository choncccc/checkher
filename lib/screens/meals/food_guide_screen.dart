import 'package:flutter/material.dart';

import '../../content/foods.dart';
import '../../theme.dart';
import '../../widgets/menu_page_header.dart';

const _warningColor = Color(0xFFB3261E);

/// Meal Guide → PMOS friendly foods: every food, filtered by category or name.
class FoodGuideScreen extends StatefulWidget {
  const FoodGuideScreen({super.key});

  @override
  State<FoodGuideScreen> createState() => _FoodGuideScreenState();
}

class _FoodGuideScreenState extends State<FoodGuideScreen> {
  FoodCategory? _category; // null means all
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = [
      for (final f in foods)
        if ((_category == null || f.category == _category) &&
            f.name.toLowerCase().contains(q))
          f,
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const MenuPageHeader(title: 'PMOS FRIENDLY FOODS'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Search foods',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('All', null),
                for (final c in FoodCategory.values) _chip(c.label, c),
              ],
            ),
          ),
          Expanded(
            child: shown.isEmpty
                ? const Center(
                    child: Text(
                      'No foods found',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: shown.length + 1,
                    itemBuilder: (context, i) => i == shown.length
                        ? const _Disclaimer()
                        : _FoodCard(
                            key: ValueKey(shown[i].name),
                            food: shown[i],
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, FoodCategory? category) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12.5)),
        selected: _category == category,
        onSelected: (_) => setState(() => _category = category),
        selectedColor: AppColors.aquaSoft,
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.panel),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  const _FoodCard({super.key, required this.food});

  final Food food;

  @override
  Widget build(BuildContext context) {
    final warning = food.warning;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: AppColors.panel, width: 1.2),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        shape: shape,
        collapsedShape: shape,
        iconColor: AppColors.deepTeal,
        collapsedIconColor: AppColors.deepTeal,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(
          food.name,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
        // In the collapsed row too, so nobody has to open it to see a warning.
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Serving: ${food.serving}', style: _small),
            if (warning != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      size: 16,
                      color: _warningColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        warning,
                        style: _small.copyWith(
                          color: _warningColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        children: [
          const _Heading('Nutrition per 100 g'),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final (label, value) in food.nutrition)
                _NutritionChip(label: label, value: value),
            ],
          ),
          const _Heading('Key nutrients'),
          Text(food.nutrients, style: _body),
          const _Heading('Why it helps'),
          Text(food.benefit, style: _body),
        ],
      ),
    );
  }
}

const _small = TextStyle(fontSize: 12, color: AppColors.inkSoft);
const _body = TextStyle(fontSize: 13, height: 1.45);

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: AppColors.deepTeal,
        ),
      ),
    );
  }
}

class _NutritionChip extends StatelessWidget {
  const _NutritionChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.aquaPale,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label.isEmpty ? value : '$label: $value',
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        'General nutrition information, not medical advice. Check with a '
        'qualified healthcare professional before changing your diet, '
        'especially if you take regular medication.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          color: AppColors.inkSoft,
        ),
      ),
    );
  }
}
