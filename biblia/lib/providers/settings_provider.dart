import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppFontSize { medio, grande, extraGrande }

extension AppFontSizeX on AppFontSize {
  double get scale {
    switch (this) {
      case AppFontSize.medio:
        return 1.0;
      case AppFontSize.grande:
        return 1.3;
      case AppFontSize.extraGrande:
        return 1.6;
    }
  }

  String get label {
    switch (this) {
      case AppFontSize.medio:
        return 'Médio';
      case AppFontSize.grande:
        return 'Grande';
      case AppFontSize.extraGrande:
        return 'Extra grande';
    }
  }
}

const _kThemeModeKey = 'theme_mode';
const _kFontSizeKey = 'font_size';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  AppFontSize _fontSize = AppFontSize.grande;

  ThemeMode get themeMode => _themeMode;
  AppFontSize get fontSize => _fontSize;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_kThemeModeKey);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == themeStr,
        orElse: () => ThemeMode.dark,
      );
    }
    final fontStr = prefs.getString(_kFontSizeKey);
    if (fontStr != null) {
      _fontSize = AppFontSize.values.firstWhere(
        (f) => f.name == fontStr,
        orElse: () => AppFontSize.grande,
      );
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
  }

  Future<void> setFontSize(AppFontSize size) async {
    _fontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontSizeKey, size.name);
  }
}
