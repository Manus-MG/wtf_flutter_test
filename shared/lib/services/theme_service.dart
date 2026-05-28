import 'package:flutter/material.dart';

abstract class ThemeService {
  Future<ThemeMode> loadThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
}
