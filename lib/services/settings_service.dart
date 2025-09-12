import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService extends ChangeNotifier {
  static const String _kDarkMode = 'settings_dark_mode';
  static const String _kPushNotif = 'settings_push_notif';
  static const String _kMailNotif = 'settings_mail_notif';

  bool _darkMode = true;
  bool _pushNotification = true;
  bool _mailNotification = false;
  bool _initialized = false;

  bool get darkMode => _darkMode;
  bool get pushNotification => _pushNotification;
  bool get mailNotification => _mailNotification;
  bool get initialized => _initialized;

  Future<void> init({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_kDarkMode) ?? true;
    _pushNotification = prefs.getBool(_kPushNotif) ?? true;
    _mailNotification = prefs.getBool(_kMailNotif) ?? false;

    if (userId != null && userId.isNotEmpty) {
      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
        final data = doc.data();
        if (data != null) {
          if (data['pushNotification'] is bool) {
            _pushNotification = data['pushNotification'] as bool;
            await prefs.setBool(_kPushNotif, _pushNotification);
          }
          if (data['mailNotification'] is bool) {
            _mailNotification = data['mailNotification'] as bool;
            await prefs.setBool(_kMailNotif, _mailNotification);
          }
        }
      } catch (_) {}
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, _darkMode);
  }

  Future<void> togglePushNotification(bool value, {String? userId}) async {
    _pushNotification = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPushNotif, _pushNotification);
    if (userId != null && userId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'pushNotification': _pushNotification},
        );
      } catch (_) {}
    }
  }

  Future<void> toggleMailNotification(bool value, {String? userId}) async {
    _mailNotification = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMailNotif, _mailNotification);
    if (userId != null && userId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'mailNotification': _mailNotification},
        );
      } catch (_) {}
    }
  }
}
