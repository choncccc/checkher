import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/reminder_repository.dart';
import '../data/services.dart';
import '../models/user.dart';
import '../theme.dart';
import '../widgets/logo.dart';

/// Page 4: Home dashboard — greeting, cycle day card and today's reminders.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.onUserChanged,
  });

  final AppUser user;
  final ValueChanged<AppUser> onUserChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Time-of-day greeting. Late night (before 5 AM) still counts as evening.
String greetingFor(DateTime t) {
  if (t.hour >= 5 && t.hour < 12) return 'Good Morning';
  if (t.hour >= 12 && t.hour < 18) return 'Good Afternoon';
  return 'Good Evening';
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Reminder>? _reminders;
  DateTime _now = DateTime.now();
  Timer? _clock;

  DateTime get _today => DateTime(_now.year, _now.month, _now.day);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Keep the greeting, date and reminders current while the app stays open.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
  }

  @override
  void dispose() {
    _clock?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  void _tick() {
    final previousDay = _today;
    final now = DateTime.now();
    if (now.hour == _now.hour && now.day == _now.day) return;
    setState(() => _now = now);
    if (_today != previousDay) _load(); // new day: fresh reminder checklist
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reminders ?? _load();
  }

  Future<void> _load() async {
    final list = await Services.of(
      context,
    ).reminders.forDay(widget.user.id, _today);
    if (mounted) setState(() => _reminders = list);
  }

  Future<void> _toggle(Reminder r) async {
    await Services.of(context).reminders.setDone(r.id, _today, !r.done);
    await _load();
  }

  Future<void> _setPeriodStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.user.lastPeriodStart ?? now,
      firstDate: now.subtract(const Duration(days: 120)),
      lastDate: now,
      helpText: 'First day of your last period',
    );
    if (picked == null || !mounted) return;
    final updated = await Services.of(
      context,
    ).auth.updateCycle(widget.user, lastPeriodStart: picked);
    widget.onUserChanged(updated);
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature logging is coming soon.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.user.displayName.split(' ').first;
    final reminders = _reminders;
    final done = reminders?.where((r) => r.done).length ?? 0;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              const CheckHerLogo(height: 48, showTagline: false),
              const Spacer(),
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.aqua,
                child: Text(
                  firstName.isEmpty ? '?' : firstName[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${greetingFor(_now)}, $firstName!',
            style: displayStyle.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('EEEE, MMMM d, y').format(_today),
            style: const TextStyle(fontSize: 14, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 18),
          _CycleCard(
            user: widget.user,
            today: _today,
            onLog: _comingSoon,
            onViewCalendar: _setPeriodStart,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text(
                "Today's Reminders",
                style: displayStyle.copyWith(fontSize: 22),
              ),
              const Spacer(),
              if (reminders != null)
                Text(
                  '$done of ${reminders.length} done',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepTeal,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (reminders != null && reminders.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: done / reminders.length),
                duration: const Duration(milliseconds: 350),
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  color: AppColors.deepTeal,
                  backgroundColor: AppColors.aquaSoft,
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (reminders == null)
            const Center(child: CircularProgressIndicator())
          else
            for (final r in reminders)
              _ReminderTile(reminder: r, onTap: () => _toggle(r)),
        ],
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  const _CycleCard({
    required this.user,
    required this.today,
    required this.onLog,
    required this.onViewCalendar,
  });

  final AppUser user;
  final DateTime today;
  final ValueChanged<String> onLog;
  final VoidCallback onViewCalendar;

  @override
  Widget build(BuildContext context) {
    final day = user.cycleDayOn(today);
    final onPeriod = user.isOnPeriodOn(today);
    final daysToNext = day == null ? null : user.cycleLength - day + 1;
    const logs = [
      (Icons.water_drop_outlined, 'Flow'),
      (Icons.bolt, 'Pain'),
      (Icons.grid_view_rounded, 'Symptoms'),
      (Icons.sentiment_satisfied_alt, 'Mood'),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.aqua,
        borderRadius: BorderRadius.circular(28),
        boxShadow: softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                for (final (icon, label) in logs)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _SoftPill(
                      icon: icon,
                      label: label,
                      onTap: () => onLog(label),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'CYCLE DAY',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          value: day == null ? 0 : day / user.cycleLength,
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                          color: onPeriod
                              ? AppColors.periodRed
                              : AppColors.deepTeal,
                          backgroundColor: Colors.white.withAlpha(140),
                        ),
                      ),
                      Text(
                        day?.toString() ?? '–',
                        style: displayStyle.copyWith(fontSize: 48, height: 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (day == null)
                  const Text(
                    'Set your period date',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: onPeriod
                          ? AppColors.periodRed
                          : AppColors.deepTeal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      onPeriod ? 'On Period' : 'Not on Period',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Next period in $daysToNext day${daysToNext == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
                const SizedBox(height: 8),
                _SoftPill(
                  icon: Icons.calendar_month,
                  label: day == null ? 'Set Date' : 'View Calendar',
                  onTap: onViewCalendar,
                  small: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.small = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.aquaPale,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: small ? 6 : 9,
            horizontal: 12,
          ),
          child: Row(
            children: [
              Icon(icon, size: small ? 16 : 20, color: AppColors.deepTeal),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: small ? 11 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder, required this.onTap});

  final Reminder reminder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = reminder.done;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: done ? 0.7 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: softShadow,
          ),
          child: Material(
            color: AppColors.aqua,
            borderRadius: BorderRadius.circular(32),
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: done ? AppColors.deepTeal : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.deepTeal, width: 6),
                      ),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        scale: done ? 1 : 0,
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        reminder.title,
                        style: displayStyle.copyWith(
                          fontSize: 20,
                          decoration: done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
