import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  SettingsProvider({required this.prefs}) {
    _load();
  }

  static const _notificationsKey = 'SETTINGS_NOTIFICATIONS';

  bool notificationsEnabled = true;

  void _load() {
    notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled = enabled;
    await prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }
}