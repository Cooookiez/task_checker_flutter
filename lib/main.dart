
import 'package:flutter/material.dart';
import 'package:task_checker_flutter/services/notification_settings_service.dart';

import 'screens/add_edit_task_screen.dart';
import 'screens/event_list_screen.dart';
import 'services/notification_controller.dart';
import 'services/task_database_service.dart';

void main() async {
  // Ensure Flutter is initialized before using any platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final db = await TaskDatabaseService.instance.database;

  // Initialize notifications
  await NotificationController.initializeLocalNotifications();
  await NotificationController.initializeIsolateReceivePort();

  // Pre-load notification settings for quicker access later
  // This is optional but may improve initial app loading experience
  final settingsService = NotificationSettingsService();
  await settingsService.getInterval();
  await settingsService.getEnabled();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Add the navigator key for use in notifications
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Set the navigator key
      navigatorKey: navigatorKey,
      title: 'SnapClick',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: EventListScreen.id,
      routes: {
        EventListScreen.id: (context) => const EventListScreen(),
        AddEditTaskScreen.id: (context) => const AddEditTaskScreen(),
      },
    );
  }
}