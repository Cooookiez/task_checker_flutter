import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsService {
  // Singleton pattern
  static final NotificationSettingsService _instance = NotificationSettingsService._internal();

  factory NotificationSettingsService() {
    return _instance;
  }

  NotificationSettingsService._internal();

  // Keys for SharedPreferences
  static const String _intervalKey = 'notification_interval';
  static const String _enabledKey = 'notifications_enabled';

  // Default values
  static const int defaultInterval = 5;
  static const bool defaultEnabled = false;

  // Save notification interval
  Future<bool> saveInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_intervalKey, minutes);
  }

  // Get notification interval
  Future<int> getInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_intervalKey) ?? defaultInterval;
  }

  // Save notification enabled state
  Future<bool> saveEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_enabledKey, enabled);
  }

  // Get notification enabled state
  Future<bool> getEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? defaultEnabled;
  }
}