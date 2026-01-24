import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({SharedPreferences? preferences})
    : _preferencesFuture = preferences != null
          ? Future<SharedPreferences>.value(preferences)
          : SharedPreferences.getInstance() {
    _loadTheme();
  }

  static const _themeKey = 'theme_mode';

  final Future<SharedPreferences> _preferencesFuture;

  int _mutationId = 0;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> setTheme(ThemeMode mode) async {
    _mutationId++;
    if (_themeMode == mode) {
      final prefs = await _preferencesFuture;
      await prefs.setString(_themeKey, _encodeThemeMode(_themeMode));
      return;
    }

    _themeMode = mode;
    notifyListeners();

    final prefs = await _preferencesFuture;
    await prefs.setString(_themeKey, _encodeThemeMode(_themeMode));
  }

  Future<void> _loadTheme() async {
    final startedAtMutation = _mutationId;
    final prefs = await _preferencesFuture;
    final stored = prefs.getString(_themeKey);
    if (stored == null) return;
    final mode = _decodeThemeMode(stored);
    if (mode == null) return;

    // If the user changed theme while we were loading, do not overwrite.
    if (startedAtMutation != _mutationId) return;

    _themeMode = mode;
    notifyListeners();
  }

  String _encodeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode? _decodeThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
}
