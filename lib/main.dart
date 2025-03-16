import 'package:flutter/material.dart';
import 'package:task_checker_flutter/screens/event_list_screen.dart';
import 'package:task_checker_flutter/screens/add_edit_task_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Checker',
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