import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/medication_repository.dart';
import '../../data/services.dart';
import '../../theme.dart';
import '../../widgets/menu_page_header.dart';

/// "8:00 AM". Spelled out because `DateFormat.jm` puts a narrow no-break space
/// before AM/PM, which Poppins doesn't draw well.
String _formatTime(int minutes) => DateFormat(
  'h:mm a',
).format(DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));

bool _isDaytime(int minutes) => minutes >= 5 * 60 && minutes < 18 * 60;

/// Page 20: the next dose, today's schedule and adding medication. Each entry
/// repeats daily; its switch turns the reminder on or off and tapping it edits.
class SupplementReminderScreen extends StatefulWidget {
  const SupplementReminderScreen({super.key, required this.userId});

  final int userId;

  @override
  State<SupplementReminderScreen> createState() =>
      _SupplementReminderScreenState();
}

class _SupplementReminderScreenState extends State<SupplementReminderScreen>
    with WidgetsBindingObserver {
  List<Medication>? _meds;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Moves the Next Reminder card on as doses pass.
    _clock = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _clock?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _meds ?? _load();
  }

  MedicationRepository get _repo => Services.of(context).medications;

  Future<void> _load() async {
    final meds = await _repo.forUser(widget.userId);
    if (mounted) setState(() => _meds = meds);
  }

  /// Without permission the schedule still saves but nothing would alert, so
  /// say so rather than let someone rely on it.
  Future<void> _ensurePermission() async {
    final messenger = ScaffoldMessenger.of(context);
    if (await _repo.requestAlertPermission()) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          "Notifications are off, so reminders won't alert you. "
          "You can allow them in your phone's settings.",
        ),
      ),
    );
  }

  Future<void> _edit([Medication? existing]) async {
    final repo = _repo;
    final result = await showModalBottomSheet<_SheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _MedicationSheet(existing: existing),
    );
    if (result == null) return;
    if (result.delete) {
      await repo.delete(widget.userId, existing!.id);
    } else if (existing == null) {
      await repo.add(
        widget.userId,
        name: result.name,
        note: result.note,
        minutes: result.minutes,
      );
    } else {
      await repo.update(
        widget.userId,
        existing.id,
        name: result.name,
        note: result.note,
        minutes: result.minutes,
      );
    }
    await _load();
    if (!result.delete && mounted) await _ensurePermission();
  }

  Future<void> _toggle(Medication m, bool enabled) async {
    await _repo.setEnabled(widget.userId, m.id, enabled);
    await _load();
    if (enabled && mounted) await _ensurePermission();
  }

  @override
  Widget build(BuildContext context) {
    final meds = _meds;
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Column(
        children: [
          const MenuPageHeader(title: 'SUPPLEMENT REMINDER'),
          Expanded(
            child: meds == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    children: [
                      _NextReminderCard(next: nextDoses(meds, DateTime.now())),
                      const SizedBox(height: 16),
                      _ScheduleCard(
                        meds: meds,
                        onAdd: _edit,
                        onEdit: _edit,
                        onToggle: _toggle,
                      ),
                      const SizedBox(height: 16),
                      const _DontForgetBanner(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _NextReminderCard extends StatelessWidget {
  const _NextReminderCard({required this.next});

  final ({List<Medication> doses, bool tomorrow})? next;

  @override
  Widget build(BuildContext context) {
    final next = this.next;
    final minutes = next?.doses.first.minutes;
    final more = next == null ? 0 : next.doses.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  next?.tomorrow == true
                      ? 'Next Reminder · Tomorrow'
                      : 'Next Reminder',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (minutes != null) ...[
                      _TimeOfDayIcon(minutes: minutes, size: 30),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        minutes == null ? 'None set' : _formatTime(minutes),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  next == null
                      ? 'Add a medication to get reminders'
                      : '${next.doses.first.name}'
                            '${more > 0 ? ' +$more more' : ''}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.aquaPale,
            child: Icon(Icons.medication, size: 44, color: Color(0xFF7E3FD1)),
          ),
        ],
      ),
    );
  }
}

class _TimeOfDayIcon extends StatelessWidget {
  const _TimeOfDayIcon({required this.minutes, this.size = 40});

  final int minutes;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _isDaytime(minutes)
        ? Icon(Icons.wb_sunny, size: size, color: const Color(0xFFFFC800))
        : Icon(
            Icons.nightlight_round,
            size: size,
            color: const Color(0xFF7E3FD1),
          );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.meds,
    required this.onAdd,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Medication> meds;
  final VoidCallback onAdd;
  final ValueChanged<Medication> onEdit;
  final void Function(Medication, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.panel, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 10),
            child: Text(
              "TODAY'S SCHEDULE",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          if (meds.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 4, 8, 14),
              child: Text(
                'Nothing scheduled yet.',
                style: TextStyle(color: AppColors.inkSoft),
              ),
            ),
          for (final m in meds)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DoseTile(
                medication: m,
                onTap: () => onEdit(m),
                onToggle: (on) => onToggle(m, on),
              ),
            ),
          OutlinedButton(
            onPressed: onAdd,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              side: const BorderSide(color: AppColors.panel, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: const Text(
              '+ Add Medication',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseTile extends StatelessWidget {
  const _DoseTile({
    required this.medication,
    required this.onTap,
    required this.onToggle,
  });

  final Medication medication;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final m = medication;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.panel, width: 1.5),
    );
    return Material(
      color: Colors.transparent,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
          child: Row(
            children: [
              _TimeOfDayIcon(minutes: m.minutes),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(m.minutes),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(m.name, style: const TextStyle(fontSize: 13.5)),
                    if (m.note.isNotEmpty)
                      Text(m.note, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              Switch(
                value: m.enabled,
                onChanged: onToggle,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.deepTeal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DontForgetBanner extends StatelessWidget {
  const _DontForgetBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF5ED8C6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Text(
            "Don't Forget!",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4B3FB5),
            ),
          ),
          Text(
            'Consistency is the key for a better health.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SheetResult {
  const _SheetResult({
    this.name = '',
    this.note = '',
    this.minutes = 0,
    this.delete = false,
  });

  final String name;
  final String note;
  final int minutes;
  final bool delete;
}

/// Adds a medication, or edits or deletes [existing].
class _MedicationSheet extends StatefulWidget {
  const _MedicationSheet({this.existing});

  final Medication? existing;

  @override
  State<_MedicationSheet> createState() => _MedicationSheetState();
}

class _MedicationSheetState extends State<_MedicationSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _note = TextEditingController(text: widget.existing?.note);
  late int _minutes = widget.existing?.minutes ?? 8 * 60;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _minutes ~/ 60, minute: _minutes % 60),
    );
    if (picked != null) {
      setState(() => _minutes = picked.hour * 60 + picked.minute);
    }
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      _SheetResult(
        name: _name.text.trim(),
        note: _note.text.trim(),
        minutes: _minutes,
      ),
    );
  }

  Future<void> _delete() async {
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this medication?'),
        content: Text('${widget.existing!.name} will stop reminding you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.periodRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) nav.pop(const _SheetResult(delete: true));
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              editing ? 'Edit Medication' : 'Add Medication',
              textAlign: TextAlign.center,
              style: displayStyle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Name and dose',
                hintText: 'e.g. Metformin 300 mg',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Enter the name of the medication'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'When to take it (optional)',
                hintText: 'e.g. After Breakfast',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickTime,
              icon: _TimeOfDayIcon(minutes: _minutes, size: 22),
              label: Text(
                'Remind me daily at ${_formatTime(_minutes)}',
                style: const TextStyle(color: AppColors.ink),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.panel, width: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.deepTeal,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            if (editing)
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.periodRed,
                ),
                child: const Text('Delete'),
              ),
          ],
        ),
      ),
    );
  }
}
