import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  late Locale _locale;

  Locale get locale => _locale;

  // Constructor to initialize with the default locale
  LocalizationService() {
    _locale = Locale('en'); // Default locale is English
    initLocale();
  }

  // Method to initialize the locale from SharedPreferences
  Future<void> initLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
    notifyListeners();
  }

  // Method to change the app's locale
  Future<void> changeLocale(Locale newLocale) async {
    if (_locale != newLocale) {
      _locale = newLocale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', newLocale.languageCode);
      notifyListeners();
    }
  }
}
