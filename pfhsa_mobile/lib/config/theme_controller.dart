import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton controller for the light/dark mode toggle.
/// A singleton (rather than a Provider) so `AppColors` static getters
/// can read it directly without every widget needing a BuildContext lookup.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _prefsKey = 'pfhsa_dark_mode';

  bool _isDark = false;
  bool get isDark => _isDark;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_prefsKey) ?? false;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, _isDark);
  }
}
