import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/period_repository.dart';
import '../../data/services.dart';
import '../../models/user.dart';
import '../../theme.dart';
import '../../widgets/logo.dart';

const _panel = Color(0xFF3FD9C4);

Color flowColor(BleedingFlow flow) => switch (flow) {
  BleedingFlow.light => const Color(0xFFF59A8A),
  BleedingFlow.moderate => const Color(0xFFF2403F),
  BleedingFlow.heavy => const Color(0xFF9B1C1C),
};

/// Scalloped seal that marks a bleeding day, as in the layout.
const _sealShape = StarBorder(
  points: 14,
  innerRadiusRatio: 0.88,
  pointRounding: 0.6,
  valleyRounding: 0.4,
);

/// Unlogged days the cycle says are period days: a pale seal, so they stand
/// out without looking logged.
const _expectedFill = Color(0x40F59A8A);
final _expectedMark = ShapeDecoration(
  color: _expectedFill,
  shape: _sealShape.copyWith(
    side: BorderSide(color: flowColor(BleedingFlow.light), width: 2),
  ),
);

/// Pages 18–19: Menstrual Cycle Calendar. Opens on the current month, where
/// a tap logs or clears a bleeding day and a double tap changes how heavy it
/// was. Tapping the month title shows the whole year (page 18).
class CycleCalendarScreen extends StatefulWidget {
  const CycleCalendarScreen({
    super.key,
    required this.user,
    required this.onUserChanged,
  });

  final AppUser user;
  final ValueChanged<AppUser> onUserChanged;

  @override
  State<CycleCalendarScreen> createState() => _CycleCalendarScreenState();
}

class _CycleCalendarScreenState extends State<CycleCalendarScreen> {
  late AppUser _user = widget.user;
  late DateTime _month = DateTime(_today.year, _today.month);
  bool _yearView = false;
  int? _loadedYear;
  Map<DateTime, BleedingFlow> _flows = {};

  DateTime get _today => DateUtils.dateOnly(DateTime.now());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadedYear ?? _load(_month.year);
  }

  /// Loads a whole year at a time, which covers both views.
  Future<void> _load(int year) async {
    final flows = await Services.of(
      context,
    ).periods.forRange(_user.id, DateTime(year), DateTime(year, 12, 31));
    if (!mounted) return;
    setState(() {
      _flows = flows;
      _loadedYear = year;
    });
  }

  void _showMonth(DateTime month) {
    setState(() {
      _month = month;
      _yearView = false;
    });
    if (month.year != _loadedYear) _load(month.year);
  }

  void _showYear(int year) {
    setState(() {
      _month = DateTime(year, _month.month);
      _yearView = true;
    });
    if (year != _loadedYear) _load(year);
  }

  /// How many days before the period start a new start still counts as
  /// that period starting earlier, rather than as an older period.
  static const _backdateWindow = 7;

  bool _rejectFuture(DateTime day) {
    if (!day.isAfter(_today)) return false;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text("You can't log days in the future.")),
      );
    return true;
  }

  Future<void> _setFlow(DateTime day, BleedingFlow? flow) async {
    if (_rejectFuture(day)) return;
    // Only days from the period start on take a severity; an earlier day
    // has to be made the start first (long press).
    final start = _start;
    if (flow != null &&
        !_flows.containsKey(day) &&
        start != null &&
        day.isBefore(start)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'This is before your period start '
              '(${DateFormat('MMMM d').format(start)}). Long-press it to make '
              'it the first day of your period.',
            ),
          ),
        );
      return;
    }
    final periods = Services.of(context).periods;
    setState(() {
      if (flow == null) {
        _flows.remove(day);
      } else {
        _flows[day] = flow;
      }
    });
    await periods.setFlow(_user.id, day, flow);
    // Keep the Home cycle day in step with what was logged. Only a new
    // period moves the start; days logged inside the current period leave
    // it alone.
    final latest = await periods.latestPeriodStart(_user.id);
    final current = _start;
    if (latest != null &&
        (current == null ||
            latest.difference(current).inDays >= _user.cycleLength ~/ 2)) {
      await _saveStart(latest);
    }
  }

  /// Makes [day] the first day of the period, logged with [flow].
  ///
  /// Moving the start earlier clears the days logged from the old start
  /// onward; moving it later clears the mistaken days before [day]. Either
  /// way they can be logged again, and Undo puts everything back.
  Future<void> _moveStart(DateTime day, BleedingFlow flow) async {
    final periods = Services.of(context).periods;
    final messenger = ScaffoldMessenger.of(context);
    final oldStart = _start;
    final previous = _flows[day];
    DateTime shift(DateTime d, int days) =>
        DateTime(d.year, d.month, d.day + days);
    var cleared = <DateTime, BleedingFlow>{};
    if (oldStart != null &&
        day.isBefore(oldStart) &&
        oldStart.difference(day).inDays <= _backdateWindow) {
      // The old period: its expected days plus any logged days running on.
      var end = shift(oldStart, _user.periodLength - 1);
      while (_flows.containsKey(shift(end, 1))) {
        end = shift(end, 1);
      }
      cleared = await periods.clearRange(_user.id, shift(day, 1), end);
    } else if (oldStart != null &&
        day.isAfter(oldStart) &&
        day.difference(oldStart).inDays < _user.cycleLength ~/ 2) {
      cleared = await periods.clearRange(_user.id, oldStart, shift(day, -1));
    }
    await periods.setFlow(_user.id, day, flow);
    if (!mounted) return;
    setState(() {
      _flows.removeWhere((d, _) => cleared.containsKey(d));
      _flows[day] = flow;
    });
    await _saveStart(day);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Period start moved to ${DateFormat('MMMM d').format(day)}.',
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.aqua,
            onPressed: () => _undoMove(day, previous, oldStart, cleared),
          ),
        ),
      );
  }

  Future<void> _undoMove(
    DateTime day,
    BleedingFlow? previous,
    DateTime? oldStart,
    Map<DateTime, BleedingFlow> cleared,
  ) async {
    final periods = Services.of(context).periods;
    await periods.setFlow(_user.id, day, previous);
    for (final e in cleared.entries) {
      await periods.setFlow(_user.id, e.key, e.value);
    }
    if (!mounted) return;
    setState(() {
      if (previous == null) {
        _flows.remove(day);
      } else {
        _flows[day] = previous;
      }
      _flows.addAll(cleared);
    });
    if (oldStart != null) await _saveStart(oldStart);
  }

  /// Long press: lets the user pick any past day as the first day of the
  /// period, e.g. to move a mistaken start date later.
  Future<void> _onLongPress(DateTime day) async {
    if (_rejectFuture(day)) return;
    if (day == _start) return;
    final flow = await showModalBottomSheet<BleedingFlow>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Make ${DateFormat('MMMM d').format(day)} the first day of '
                'your period?',
                style: displayStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              const Text(
                'How heavy was your bleeding that day?',
                style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final f in BleedingFlow.values) ...[
                    if (f != BleedingFlow.light) const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, f),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: BorderSide(color: flowColor(f), width: 2),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 4,
                          ),
                        ),
                        child: Text(
                          f.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (flow != null && mounted) await _moveStart(day, flow);
  }

  /// Saves [start] as the period start, which the Home cycle day uses.
  Future<void> _saveStart(DateTime start) async {
    if (DateUtils.isSameDay(start, _user.lastPeriodStart)) return;
    final updated = await Services.of(
      context,
    ).auth.updateCycle(_user, lastPeriodStart: start);
    if (!mounted) return;
    setState(() => _user = updated);
    widget.onUserChanged(updated);
  }

  void _onTap(DateTime day) =>
      _setFlow(day, _flows[day] == null ? BleedingFlow.light : null);

  void _onDoubleTap(DateTime day) =>
      _setFlow(day, _flows[day]?.next ?? BleedingFlow.light);

  /// Period days implied by the saved start date (such as the one entered
  /// at sign-up) and the cycles after it, past or upcoming.
  bool _isExpected(DateTime day) => _user.isOnPeriodOn(day);

  /// First day of the current period, e.g. the date entered at sign-up.
  DateTime? get _start {
    final start = _user.lastPeriodStart;
    return start == null ? null : DateUtils.dateOnly(start);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back from the year overview returns to the month.
      canPop: !_yearView,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _yearView = false);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                const LogoHeader(),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: PillTitle('Menstrual Cycle Calendar', fontSize: 20),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: _loadedYear == null
                        ? const Center(child: CircularProgressIndicator())
                        : _yearView
                        ? _buildYear()
                        : _buildMonth(),
                  ),
                ),
              ],
            ),
            SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonth() {
    final today = _today;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                color: AppColors.aqua,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    _Arrow(
                      left: true,
                      onTap: () =>
                          _showMonth(DateTime(_month.year, _month.month - 1)),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showYear(_month.year),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            DateFormat('MMMM  y').format(_month).toUpperCase(),
                            textAlign: TextAlign.center,
                            style: displayStyle.copyWith(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                    _Arrow(
                      left: false,
                      onTap: () =>
                          _showMonth(DateTime(_month.year, _month.month + 1)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (final d in const [
                          'S',
                          'M',
                          'T',
                          'W',
                          'T',
                          'F',
                          'S',
                        ])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepTeal,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (final week in _weeks(_month))
                      Row(
                        children: [
                          for (final day in week)
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: day == null
                                    ? const SizedBox()
                                    : _DayCell(
                                        day: day,
                                        flow: _flows[day],
                                        expected: _isExpected(day),
                                        isToday: day == today,
                                        isStart: day == _start,
                                        onTap: () => _onTap(day),
                                        onDoubleTap: () => _onDoubleTap(day),
                                        onLongPress: () => _onLongPress(day),
                                      ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_startPrompt() case final prompt?) ...[
          const SizedBox(height: 14),
          prompt,
        ],
        const SizedBox(height: 14),
        const _Legend(),
      ],
    );
  }

  /// Asks how heavy the period start day was while it isn't logged yet, so
  /// the date entered at sign-up gets a severity without a double tap.
  Widget? _startPrompt() {
    final start = _start;
    if (start == null ||
        _flows.containsKey(start) ||
        start.isAfter(_today) ||
        start.year != _month.year ||
        start.month != _month.month) {
      return null;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.deepTeal, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your period started on ${DateFormat('MMMM d').format(start)}.',
            style: displayStyle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          const Text(
            'How heavy was your bleeding that day? Wrong date? Long-press '
            'the right day to move it.',
            style: TextStyle(fontSize: 13, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final f in BleedingFlow.values) ...[
                if (f != BleedingFlow.light) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _setFlow(start, f),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: BorderSide(color: flowColor(f), width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      f.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYear() {
    final year = _month.year;
    Widget month(int m) => _MiniMonth(
      month: DateTime(year, m),
      flows: _flows,
      isExpected: _isExpected,
      start: _start,
      today: _today,
      onTap: () => _showMonth(DateTime(year, m)),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Arrow(left: true, onTap: () => _showYear(year - 1)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.aqua,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text('$year', style: displayStyle.copyWith(fontSize: 28)),
            ),
            _Arrow(left: false, onTap: () => _showYear(year + 1)),
          ],
        ),
        const SizedBox(height: 14),
        for (var m = 1; m <= 12; m += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: month(m)),
                const SizedBox(width: 12),
                Expanded(child: month(m + 1)),
              ],
            ),
          ),
      ],
    );
  }
}

/// The days of [month] split into Sunday-first weeks, padded with nulls.
List<List<DateTime?>> _weeks(DateTime month) {
  final lead = DateTime(month.year, month.month).weekday % 7;
  final count = DateUtils.getDaysInMonth(month.year, month.month);
  final cells = <DateTime?>[
    for (var i = 0; i < lead; i++) null,
    for (var d = 1; d <= count; d++) DateTime(month.year, month.month, d),
  ];
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return [for (var i = 0; i < cells.length; i += 7) cells.sublist(i, i + 7)];
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.left, required this.onTap});

  final bool left;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: left ? 'Previous' : 'Next',
      icon: Icon(
        left ? Icons.arrow_left_rounded : Icons.arrow_right_rounded,
        size: 36,
        color: AppColors.deepTeal,
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.flow,
    required this.expected,
    required this.isToday,
    required this.isStart,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
  });

  final DateTime day;
  final BleedingFlow? flow;
  final bool expected;
  final bool isToday;
  final bool isStart; // period start day: outlined so it stays easy to find
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final flow = this.flow;
    final ShapeDecoration? mark = flow != null
        ? ShapeDecoration(color: flowColor(flow), shape: _sealShape)
        : expected
        ? _expectedMark
        : null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: isStart
              ? Border.all(color: AppColors.deepTeal, width: 2.5)
              : Border.all(color: _panel, width: 0.8),
        ),
        padding: EdgeInsets.all(isStart ? 1.5 : 3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration:
              mark ??
              (isToday
                  ? const ShapeDecoration(
                      shape: CircleBorder(
                        side: BorderSide(color: AppColors.deepTeal, width: 2),
                      ),
                    )
                  : null),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: displayStyle.copyWith(
              fontSize: 18,
              color: flow == BleedingFlow.heavy
                  ? Colors.white
                  : isToday && flow == null
                  ? AppColors.deepTeal
                  : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniMonth extends StatelessWidget {
  const _MiniMonth({
    required this.month,
    required this.flows,
    required this.isExpected,
    required this.start,
    required this.today,
    required this.onTap,
  });

  final DateTime month;
  final Map<DateTime, BleedingFlow> flows;
  final bool Function(DateTime day) isExpected;
  final DateTime? start;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.aqua,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                DateFormat('MMMM').format(month),
                textAlign: TextAlign.center,
                style: displayStyle.copyWith(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  for (final week in _weeks(month))
                    Row(
                      children: [
                        for (final day in week)
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: day == null
                                  ? const SizedBox()
                                  : _miniDay(day),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniDay(DateTime day) {
    final flow = flows[day];
    return Container(
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      foregroundDecoration: day == start
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.deepTeal, width: 1.5),
            )
          : null,
      decoration: flow != null
          ? BoxDecoration(color: flowColor(flow), shape: BoxShape.circle)
          : isExpected(day)
          ? BoxDecoration(
              color: _expectedFill,
              shape: BoxShape.circle,
              border: Border.all(color: flowColor(BleedingFlow.light)),
            )
          : day == today
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.deepTeal, width: 1.2),
            )
          : null,
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: flow == BleedingFlow.heavy ? Colors.white : AppColors.ink,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget seal(Color color, {double size = 18}) => Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(color: color, shape: _sealShape),
    );
    const caption = TextStyle(
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: AppColors.deepTeal,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              seal(flowColor(BleedingFlow.light), size: 30),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Period bleeding',
                  style: displayStyle.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'DOUBLE TAP A DAY TO ADJUST THE HEAVINESS OF BLEEDING',
            style: caption,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final f in BleedingFlow.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    seal(flowColor(f)),
                    const SizedBox(width: 6),
                    Text(f.label, style: displayStyle.copyWith(fontSize: 15)),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 18, height: 18, decoration: _expectedMark),
                  const SizedBox(width: 6),
                  Text(
                    'Expected period',
                    style: displayStyle.copyWith(fontSize: 15),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.deepTeal, width: 2.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Period start',
                    style: displayStyle.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'TAP THE CALENDAR TO ADD OR REMOVE A BLEEDING DAY\n'
              'LONG-PRESS A DAY TO MAKE IT THE FIRST DAY OF YOUR PERIOD',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                decoration: TextDecoration.underline,
                color: AppColors.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
