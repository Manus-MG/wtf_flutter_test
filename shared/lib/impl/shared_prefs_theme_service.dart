import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/theme_service.dart';

const _kThemeModeKey = 'theme_mode';

class SharedPrefsThemeService implements ThemeService {
  SharedPrefsThemeService(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<ThemeMode> loadThemeMode() async {
    final raw = _prefs.getString(_kThemeModeKey);
    if (raw == null) return ThemeMode.system;
    return ThemeMode.values.byName(raw);
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_kThemeModeKey, mode.name);
  }
}
