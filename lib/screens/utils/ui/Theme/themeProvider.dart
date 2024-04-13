import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  get themeMode => null;

  get isDarkMode => null;

  ThemeData getTheme() => _themeData;

  void toggleTheme(bool bool) {
    _themeData = _themeData == ThemeData.dark() ? ThemeData.light() : ThemeData.dark();
    notifyListeners();
  }

  Future<void> saveThemePreference(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
  }

  Future<void> loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('isDark') ?? false;
    _themeData = isDark ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
  }
}
