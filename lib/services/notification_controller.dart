import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../screens/event_list_screen.dart';
import 'notification_service.dart';

class NotificationController {
  // Singleton pattern
  static final NotificationController _instance = NotificationController._internal();

  factory NotificationController() {
    return _instance;
  }

  NotificationController._internal();

  // Initialize notifications
  static Future<void> initializeLocalNotifications() async {
    await NotificationService.initialize();

    // Set up notification listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  // To handle notification actions in background
  static Future<void> initializeIsolateReceivePort() async {
    // Get the receive port for background notifications
    final ReceivePort port = ReceivePort();

    // Register the port with a name
    final success = IsolateNameServer.registerPortWithName(
      port.sendPort,
      'notification_action_port',
    );

    if (!success) {
      // If the port name is already registered, unregister it first
      IsolateNameServer.removePortNameMapping('notification_action_port');
      IsolateNameServer.registerPortWithName(
        port.sendPort,
        'notification_action_port',
      );
    }

    // Listen to the port for notification actions
    port.listen((received) {
      // Handle notification actions received through the port
    });
  }

  // Handle notification actions
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    final payload = receivedAction.payload;

    // Navigate to the appropriate screen based on the notification action
    if (receivedAction.channelKey == 'task_checker_channel') {
      // If the app is in foreground
      if (MyApp.navigatorKey.currentState != null) {
        MyApp.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          EventListScreen.id,
              (route) => route.isFirst,
        );
      }
    }
  }

  // Called when a notification is created
  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // You can implement custom logic when a notification is created
    debugPrint('Notification created: ${receivedNotification.title}');
  }

  // Called when a notification is displayed
  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // You can implement custom logic when a notification is displayed
    debugPrint('Notification displayed: ${receivedNotification.title}');
  }

  // Called when a notification is dismissed
  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // You can implement custom logic when a notification is dismissed
    debugPrint('Notification dismissed');
  }

  // Schedule task reminder notifications based on the interval
  static Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskName,
    required String taskDescription,
    required int intervalMinutes,
  }) async {
    // Check if notifications are allowed
    bool isAllowed = await NotificationService.checkPermissions();

    if (!isAllowed) {
      isAllowed = await NotificationService.requestPermissions();
      if (!isAllowed) {
        debugPrint('Notification permission was denied');
        return;
      }
    }

    // Cancel any existing notifications for this task
    await NotificationService.cancelNotification(taskId);

    // Schedule the new notification
    await NotificationService.scheduleTaskNotification(
      taskId: taskId,
      taskName: taskName,
      taskDescription: taskDescription,
      intervalMinutes: intervalMinutes,
    );

    debugPrint('Scheduled notification for $taskName in $intervalMinutes minutes');
  }
}