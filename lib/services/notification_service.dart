import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  // IDs for different notification types
  static const int periodicReminderId = 1000;
  static const int periodicReminderIdEnd = 1024; // For cancellation range

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
          // Adding these for better reliability:
          locked: true, // Cannot be dismissed by the user
          onlyAlertOnce: false, // Alert on every notification
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

  // Check if notifications are allowed
  static Future<bool> checkPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    return isAllowed;
  }

  // Cancel all periodic notifications
  static Future<void> cancelAllPeriodicNotifications() async {
    // Cancel a range of IDs to ensure we get all periodic notifications
    for (int i = periodicReminderId; i <= periodicReminderIdEnd; i++) {
      await AwesomeNotifications().cancel(i);
    }
  }

  // Schedule app-wide periodic notifications - improved version
  static Future<void> scheduleAppReminders({
    required String title,
    required String body,
    required int intervalMinutes,
  }) async {
    // Cancel any existing periodic notifications
    await cancelAllPeriodicNotifications();

    // Only schedule if interval is greater than 0
    if (intervalMinutes <= 0) return;

    // Use repeating notifications with different strategies based on interval duration
    if (intervalMinutes < 60) {
      // For shorter intervals (less than an hour)
      // Use multiple notifications with different IDs to increase reliability

      // Strategy 1: Primary repeating notification
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: periodicReminderId,
          channelKey: 'task_checker_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationInterval(
          interval: Duration(minutes: intervalMinutes),
          repeats: true,
          preciseAlarm: true, // Use exact alarm timing
          allowWhileIdle: true, // Allow when device is in idle mode
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        ),
      );

      // Strategy 2: Backup notification with slight offset
      // This helps in case the primary one is killed by the system
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: periodicReminderId + 1,
          channelKey: 'task_checker_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          second: 30, // Offset by 30 seconds
          minute: DateTime.now().minute + (intervalMinutes ~/ 2), // Half the interval offset
          hour: null,
          day: null,
          month: null,
          year: null,
          repeats: true,
          preciseAlarm: true,
          allowWhileIdle: true,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        ),
      );
    } else {
      // For longer intervals (hourly or more)
      // Use calendar-based scheduling for better reliability
      final now = DateTime.now();

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: periodicReminderId,
          channelKey: 'task_checker_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar(
          hour: now.hour,
          minute: now.minute,
          second: 0,
          repeats: true,
          preciseAlarm: true,
          allowWhileIdle: true,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        ),
      );
    }

    // Schedule an immediate notification as a starter
    // This ensures the first notification happens right away
    // await showImmediateNotification(
    //   title: title,
    //   body: body,
    //   id: periodicReminderId + 2, // Use a different ID
    // );
  }

  // Create immediate notification
  static Future<void> showImmediateNotification({
    required String title,
    int? id,
  }) async {
    // For immediate notifications
    final notificationId = id ?? Random().nextInt(1000) + 2000; // Different range from periodic notifications

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'task_checker_channel',
        title: title,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
      ),
    );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Check if there are any scheduled notifications
  static Future<bool> hasScheduledNotifications() async {
    try {
      final pendingNotifications = await AwesomeNotifications().listScheduledNotifications();
      return pendingNotifications.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking scheduled notifications: $e');
      return false;
    }
  }
}