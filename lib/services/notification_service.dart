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

  // Schedule a notification for a specific task
  static Future<void> scheduleTaskNotification({
    required String taskId,
    required String taskName,
    required String taskDescription,
    required int intervalMinutes,
  }) async {
    // Generate a unique notification ID
    final notificationId = taskId.hashCode;

    // Calculate the next notification time based on the interval
    final scheduleTime = DateTime.now().add(Duration(minutes: intervalMinutes));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'task_checker_channel',
        title: taskName,
        body: taskDescription,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduleTime),
    );
  }

  // Create immediate notification
  static Future<void> showTaskNotification({
    required String taskId,
    required String taskName,
    required String taskDescription,
  }) async {
    // For immediate notifications
    final notificationId = taskId.hashCode + Random().nextInt(1000);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'task_checker_channel',
        title: taskName,
        body: taskDescription,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
    );
  }

  // Cancel a specific notification
  static Future<void> cancelNotification(String taskId) async {
    final notificationId = taskId.hashCode;
    await AwesomeNotifications().cancel(notificationId);
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