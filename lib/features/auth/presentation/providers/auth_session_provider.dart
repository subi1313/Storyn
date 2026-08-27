import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  AuthSessionProvider({required this.prefs});

  static const _loginTimeKey = 'AUTH_LOGIN_TIMESTAMP';
  static const _onboardingSeenKey = 'HAS_SEEN_ONBOARDING';
  static const Duration sessionDuration = Duration(hours: 8);

  Timer? _sessionTimer;

  bool get hasSeenOnboarding => prefs.getBool(_onboardingSeenKey) ?? false;

  Future<void> markOnboardingComplete() async {
    await prefs.setBool(_onboardingSeenKey, true);
  }

  void recordLogin() {
    prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
    _scheduleAutoLogout();
  }

  Future<bool> isSessionValid() async {
    final loginMillis = prefs.getInt(_loginTimeKey);
    if (loginMillis == null) return false;

    final loginTime = DateTime.fromMillisecondsSinceEpoch(loginMillis);
    final elapsed = DateTime.now().difference(loginTime);

    if (elapsed >= sessionDuration) {
      await _expireSession();
      return false;
    }

    _scheduleAutoLogout(remaining: sessionDuration - elapsed);
    return true;
  }

  void _scheduleAutoLogout({Duration? remaining}) {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(remaining ?? sessionDuration, _expireSession);
  }

  Future<void> _expireSession() async {
    await prefs.remove(_loginTimeKey);
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  void clearSession() {
    _sessionTimer?.cancel();
    prefs.remove(_loginTimeKey);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}