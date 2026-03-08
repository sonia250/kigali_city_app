import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _locationNotificationsEnabled = false;
  bool _darkMode = true;

  bool get locationNotificationsEnabled => _locationNotificationsEnabled;
  bool get darkMode => _darkMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _locationNotificationsEnabled =
        prefs.getBool('locationNotifications') ?? false;
    _darkMode = prefs.getBool('darkMode') ?? true;
    notifyListeners();
  }

  Future<void> toggleLocationNotifications() async {
    _locationNotificationsEnabled = !_locationNotificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('locationNotifications', _locationNotificationsEnabled);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    notifyListeners();
  }
}









