import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS:     iosSettings,
    );
    await _plugin.initialize(settings);
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime deadline,
  }) async {
    // Schedule reminder at the exact task deadline time (not 30 min before)
    final now = DateTime.now();
    if (deadline.isBefore(now) || deadline.isAtSameMomentAs(now)) return;

    await _plugin.zonedSchedule(
      id,
      '⏰ Task reminder',
      '"$title" is due now – time to complete it!',
      tz.TZDateTime.from(deadline, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for upcoming task deadlines',
          importance: Importance.high,
          priority:   Priority.high,
          icon:       '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> showPomodoroComplete() async {
    await _plugin.show(
      9999,
      '🍅 Pomodoro Complete!',
      'Great work! Time for a short break.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro', 'Pomodoro Timer',
          channelDescription: 'Pomodoro session notifications',
          importance: Importance.high,
          priority:   Priority.high,
          icon:       '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
