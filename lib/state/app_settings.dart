import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const _kQariKey = "selected_qari_key";
  static const _kThemeMode = "theme_mode"; // system/light/dark

  String _selectedQariKey = "01";
  ThemeMode _themeMode = ThemeMode.system;

  String get selectedQariKey => _selectedQariKey;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _selectedQariKey = sp.getString(_kQariKey) ?? "01";
    final mode = sp.getString(_kThemeMode) ?? "system";
    _themeMode = switch (mode) {
      "light" => ThemeMode.light,
      "dark" => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setQariKey(String key) async {
    _selectedQariKey = key;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kQariKey, key);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kThemeMode, switch (mode) {
      ThemeMode.light => "light",
      ThemeMode.dark => "dark",
      _ => "system",
    });
  }
}
