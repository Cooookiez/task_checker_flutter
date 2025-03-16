import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // null means use the default app icon
      [
        NotificationChannel(
          channelGroupKey: 'task_checker_channel_group',
          channelKey: 'task_checker_channel',
          channelName: 'Task Notifications',
          channelDescription: 'Notifications for task reminders',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: const Color(0xFF2196F3),
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'task_checker_channel_group',
          channelGroupName: 'Task Checker Group',
        )
      ],
      debug: true,
    );

    // Request permission
    await requestPermissions();
  }

  static Future<bool> requestPermissions() async {
    final result = await AwesomeNotifications().requestPermissionToSendNotifications();
    return result;
  }

  // Schedule app-wide periodic notifications
  static Future<void> scheduleAppReminders({
    required String title,
    required String body,
    required int intervalMinutes,
  }) async {
    // Cancel any existing periodic notifications
    await cancelAllPeriodicNotifications();

    // Generate a constant ID for app-wide notifications
    const int notificationId = 1000;

    // Only schedule if interval is greater than 0
    if (intervalMinutes > 0) {
      // For the first immediate notification after the interval
      final DateTime firstScheduleTime = DateTime.now().add(Duration(minutes: intervalMinutes));

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'task_checker_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: firstScheduleTime,
        ),
      );

      // For now, we'll use a simpler approach that works across platforms
      // This will schedule notifications at fixed times separated by the interval
      // We'll schedule up to 24 hours of notifications to ensure coverage
      const int maxSchedules = 24; // Maximum number of notifications to schedule (24 hours)
      int schedulesToCreate = (60 * 24) ~/ intervalMinutes; // How many fit in 24 hours
      schedulesToCreate = schedulesToCreate > maxSchedules ? maxSchedules : schedulesToCreate;

      for (int i = 1; i <= schedulesToCreate; i++) {
        final DateTime scheduleTime = firstScheduleTime.add(Duration(minutes: intervalMinutes * i));

        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId + i,
            channelKey: 'task_checker_channel',
            title: title,
            body: body,
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
          ),
          schedule: NotificationCalendar.fromDate(
            date: scheduleTime,
          ),
        );
      }
    }
  }

  // Create immediate notification
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    // For immediate notifications
    final notificationId = Random().nextInt(1000) + 2000; // Different range from periodic notifications

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'task_checker_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
    );
  }

  // Cancel all periodic notifications
  static Future<void> cancelAllPeriodicNotifications() async {
    const int baseNotificationId = 1000;
    const int maxSchedules = 24;

    // Cancel the first notification
    await AwesomeNotifications().cancel(baseNotificationId);

    // Cancel all scheduled notifications
    for (int i = 1; i <= maxSchedules; i++) {
      await AwesomeNotifications().cancel(baseNotificationId + i);
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Check if notifications are allowed
  static Future<bool> checkPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    return isAllowed;
  }
}