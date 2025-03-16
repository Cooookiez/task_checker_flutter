import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../screens/event_list_screen.dart';
import 'notification_service.dart';
import 'notification_settings_service.dart';

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
        // Instead of creating a new screen instance that resets state,
        // we'll use pushNamed which will preserve the existing screen if it's already in the stack
        // or navigate to it if it's not
        MyApp.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          EventListScreen.id,
              (route) => route.isFirst,
        );

        // Note: The state will be preserved because we're now loading it from
        // persistent storage in the EventListScreen's initState
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

  // Schedule app-wide periodic reminders
  static Future<void> scheduleAppReminders({
    int? intervalMinutes,
    String title = 'Task Reminder',
    String? message,
  }) async {
    // If no interval is provided, load it from settings
    int actualInterval = intervalMinutes ??
        await NotificationSettingsService().getInterval();

    // Check if notifications are allowed
    bool isAllowed = await NotificationService.checkPermissions();

    if (!isAllowed) {
      isAllowed = await NotificationService.requestPermissions();
      if (!isAllowed) {
        debugPrint('Notification permission was denied');
        return;
      }
    }

    // Default message if none provided
    final notificationMessage = message ?? 'Don\'t forget to check your tasks!';

    // Schedule periodic app-wide notifications
    await NotificationService.scheduleAppReminders(
      title: title,
      body: notificationMessage,
      intervalMinutes: actualInterval,
    );

    debugPrint('Scheduled app-wide reminders every $actualInterval minutes');
  }

  // Send an immediate notification
  static Future<void> sendImmediateNotification({
    required String title,
    required String message,
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

    await NotificationService.showImmediateNotification(
      title: title,
      body: message,
    );

    debugPrint('Sent immediate notification: $title');
  }
}