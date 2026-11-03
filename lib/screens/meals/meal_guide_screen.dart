import 'package:flutter/material.dart';

import '../../content/care_topics.dart';
import '../../content/meal_guide.dart';
import '../../data/meal_repository.dart';
import '../../data/services.dart';
import '../../theme.dart';
import '../../widgets/menu_page_header.dart';
import 'food_guide_screen.dart';
import 'meal_detail_screen.dart';

const _outline = Color(0xFFB9A2EC);
const _maxGlasses = 20;
const _maxMeals = 6;
const _kcalStep = 50;
const _minKcal = 1000;
const _maxKcal = 3000;

/// Page 21: today's water, meals and calorie goal, then shortcuts to the guide
/// topics and the recommended meals.
class MealGuideScreen extends StatefulWidget {
  const MealGuideScreen({super.key, required this.userId});

  final int userId;

  @override
  State<MealGuideScreen> createState() => _MealGuideScreenState();
}

class _MealGuideScreenState extends State<MealGuideScreen>
    with WidgetsBindingObserver {
  MealDay? _day;
  late DateTime _today = _dateNow();

  static DateTime _dateNow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Counters are per day, so start fresh if the app comes back on a new one.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _dateNow() != _today) {
      _today = _dateNow();
      _load();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _day ?? _load();
  }

  MealRepository get _repo => Services.of(context).meals;

  Future<void> _load() async {
    final day = await _repo.forDay(widget.userId, _today);
    if (mounted) setState(() => _day = day);
  }

  void _setWater(int glasses) {
    final day = _day!;
    setState(
      () => _day = MealDay(
        water: glasses,
        meals: day.meals,
        kcalGoal: day.kcalGoal,
      ),
    );
    _repo.setWater(widget.userId, _today, glasses);
  }

  void _setMeals(int meals) {
    final day = _day!;
    setState(
      () => _day = MealDay(
        water: day.water,
        meals: meals,
        kcalGoal: day.kcalGoal,
      ),
    );
    _repo.setMeals(widget.userId, _today, meals);
  }

  void _setKcalGoal(int kcal) {
    final day = _day!;
    setState(
      () =>
          _day = MealDay(water: day.water, meals: day.meals, kcalGoal: kcal),
    );
    _repo.setKcalGoal(widget.userId, kcal);
  }

  void _openTopic(MealTopic topic) {
    if (!topic.isFoodGuide) {
      _open(topic.title, topic.blocks);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FoodGuideScreen()),
    );
  }

  void _open(String title, List<CareBlock> blocks, {List<MealTag>? tags}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            MealDetailScreen(title: title, blocks: blocks, tags: tags ?? []),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = _day;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const MenuPageHeader(title: 'MEAL GUIDE'),
          Expanded(
            child: day == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                    children: [
                      _Counters(
                        day: day,
                        onWater: _setWater,
                        onMeals: _setMeals,
                        onKcalGoal: _setKcalGoal,
                      ),
                      const SizedBox(height: 10),
                      _Topics(onOpen: _openTopic),
                      const SizedBox(height: 10),
                      _Recommended(
                        onOpen: (m) => _open(m.title, m.blocks, tags: m.tags),
                      ),
                      const SizedBox(height: 14),
                      const _Banner(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Counters extends StatelessWidget {
  const _Counters({
    required this.day,
    required this.onWater,
    required this.onMeals,
    required this.onKcalGoal,
  });

  final MealDay day;
  final ValueChanged<int> onWater;
  final ValueChanged<int> onMeals;
  final ValueChanged<int> onKcalGoal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CounterCard(
            title: 'Water intake',
            icon: Icons.local_drink,
            iconColor: const Color(0xFF6A3FD1),
            value: '${day.water}',
            target: '/${MealRepository.waterGoal}',
            unit: 'Glasses',
            progress: day.water / MealRepository.waterGoal,
            barColor: const Color(0xFFB79BEA),
            decreaseLabel: 'One glass less',
            increaseLabel: 'One glass more',
            onDecrease: day.water > 0 ? () => onWater(day.water - 1) : null,
            onIncrease: day.water < _maxGlasses
                ? () => onWater(day.water + 1)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CounterCard(
            title: 'No. of Meal',
            icon: Icons.rice_bowl,
            iconColor: const Color(0xFF0A7D6C),
            value: '${day.meals}',
            target: '/${MealRepository.mealGoal}',
            unit: 'Meal',
            progress: day.meals / MealRepository.mealGoal,
            barColor: const Color(0xFF5ED8D0),
            decreaseLabel: 'One meal less',
            increaseLabel: 'One meal more',
            onDecrease: day.meals > 0 ? () => onMeals(day.meals - 1) : null,
            onIncrease: day.meals < _maxMeals
                ? () => onMeals(day.meals + 1)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CounterCard(
            title: 'Daily Goal',
            icon: Icons.local_fire_department,
            iconColor: const Color(0xFFE8622C),
            value: '${day.kcalGoal}',
            unit: 'Kcal',
            progress: (day.kcalGoal - _minKcal) / (_maxKcal - _minKcal),
            barColor: const Color(0xFFF26B6B),
            decreaseLabel: 'Lower calorie goal',
            increaseLabel: 'Raise calorie goal',
            onDecrease: day.kcalGoal > _minKcal
                ? () => onKcalGoal(day.kcalGoal - _kcalStep)
                : null,
            onIncrease: day.kcalGoal < _maxKcal
                ? () => onKcalGoal(day.kcalGoal + _kcalStep)
                : null,
          ),
        ),
      ],
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    this.target,
    required this.unit,
    required this.progress,
    required this.barColor,
    required this.decreaseLabel,
    required this.increaseLabel,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String? target;
  final String unit;
  final double progress;
  final Color barColor;
  final String decreaseLabel;
  final String increaseLabel;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    Widget arrow(IconData icon, String label, VoidCallback? onPressed) =>
        IconButton(
          onPressed: onPressed,
          tooltip: label,
          icon: Icon(icon),
          iconSize: 20,
          color: AppColors.ink,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 30, minHeight: 34),
          visualDensity: VisualDensity.compact,
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _outline),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: iconColor),
              const SizedBox(width: 3),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text.rich(
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      children: [
                        if (target != null)
                          TextSpan(
                            text: target,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(unit, style: const TextStyle(fontSize: 10.5)),
          Row(
            children: [
              arrow(Icons.chevron_left, decreaseLabel, onDecrease),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 7,
                    color: barColor,
                    backgroundColor: const Color(0xFF9E9E9E),
                  ),
                ),
              ),
              arrow(Icons.chevron_right, increaseLabel, onIncrease),
            ],
          ),
        ],
      ),
    );
  }
}

class _Topics extends StatelessWidget {
  const _Topics({required this.onOpen});

  final ValueChanged<MealTopic> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final t in mealTopics)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onOpen(t),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: t.color,
                        child: Icon(t.icon, size: 26, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
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

class _Recommended extends StatelessWidget {
  const _Recommended({required this.onOpen});

  final ValueChanged<MealOption> onOpen;

  @override
  Widget build(BuildContext context) {
    Widget row(int from) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = from; i < from + 3; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _MealCard(
                meal: mealOptions[i],
                onTap: () => onOpen(mealOptions[i]),
              ),
            ),
          ),
      ],
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _outline, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 8),
            child: Text(
              'RECOMMENDED FOR YOU',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.5,
              ),
            ),
          ),
          row(0),
          const SizedBox(height: 10),
          row(3),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onTap});

  final MealOption meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.panel, width: 1.2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    meal.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 3,
          runSpacing: 3,
          children: [for (final t in meal.tags) MealTagChip(tag: t)],
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF55D9C7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        mealGuideBanner,
        textAlign: TextAlign.center,
        style: displayStyle.copyWith(fontSize: 19, height: 1.35),
      ),
    );
  }
}
