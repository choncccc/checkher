import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'medication_repository.dart';

/// Schedules the phone's notifications. An interface so tests can replace it.
abstract class MedicationAlerts {
  Future<bool> requestPermission();

  /// Replaces every scheduled reminder with one per enabled medication.
  Future<void> sync(List<Medication> medications);

  Future<void> cancelAll();
}

/// Daily notifications through the operating system, which deliver even when
/// the app is closed. They can run a few minutes late while the phone is idle:
/// exact timing would need Android's restricted exact-alarm permission.
class DeviceMedicationAlerts implements MedicationAlerts {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  // Notifications are only supported on phones; other platforms are for
  // development and simply skip them.
  bool get _supported => Platform.isAndroid || Platform.isIOS;

  Future<void> _init() async {
    tz.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on tz.LocationNotFoundException {
      // A zone name the database doesn't know: use the app's home region.
      tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        // Asked for when the first reminder is saved, not on launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (!_supported) return true;
    await (_ready ??= _init());
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final granted =
        await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, sound: true);
    return granted ?? true;
  }

  @override
  Future<void> sync(List<Medication> medications) async {
    if (!_supported) return;
    await (_ready ??= _init());
    await _plugin.cancelAll();
    for (final m in medications.where((m) => m.enabled)) {
      await _plugin.zonedSchedule(
        id: m.id,
        title: "Don't forget your medication",
        body: [
          'Take your ${m.name} now.',
          if (m.note.isNotEmpty) m.note,
        ].join(' '),
        scheduledDate: _nextTime(m),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Supplement reminders',
            channelDescription: 'Daily reminders from your supplement schedule',
            importance: Importance.high,
            priority: Priority.high,
            // Health details stay hidden on the lock screen.
            visibility: NotificationVisibility.private,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    if (!_supported) return;
    await (_ready ??= _init());
    await _plugin.cancelAll();
  }

  tz.TZDateTime _nextTime(Medication m) {
    final now = tz.TZDateTime.now(tz.local);
    final today = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      m.hour,
      m.minute,
    );
    if (today.isAfter(now)) return today;
    // Built from the date, so a daylight-saving change can't shift the time.
    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      m.hour,
      m.minute,
    );
  }
}
