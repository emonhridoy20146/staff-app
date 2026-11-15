import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local reminders (ADR-M06): work offline at 09:00 Dhaka on the promised
/// date; FCM is only a backup.
abstract class ReminderScheduler {
  Future<void> init();
  Future<void> schedulePromise({required int id, required String businessDate, required String title, required String body});
  Future<void> cancel(int id);
}

class LocalReminderScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  @override
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
    _ready = true;
  }

  @override
  Future<void> schedulePromise({required int id, required String businessDate, required String title, required String body}) async {
    await init();
    final dhaka = tz.getLocation('Asia/Dhaka');
    final p = businessDate.split('-').map(int.parse).toList();
    final when = tz.TZDateTime(dhaka, p[0], p[1], p[2], 9);
    if (when.isBefore(tz.TZDateTime.now(dhaka))) return;
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('promises', 'Promise reminders', importance: Importance.high, priority: Priority.high),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);
}

/// Records what would be scheduled (tests, demo).
class MemoryReminderScheduler implements ReminderScheduler {
  final scheduled = <int, String>{};
  @override
  Future<void> init() async {}
  @override
  Future<void> schedulePromise({required int id, required String businessDate, required String title, required String body}) async => scheduled[id] = businessDate;
  @override
  Future<void> cancel(int id) async => scheduled.remove(id);
}

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) => LocalReminderScheduler());
