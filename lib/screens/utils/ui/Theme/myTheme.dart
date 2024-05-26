import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{
  ThemeMode themeMode =ThemeMode.dark;

  bool get isDarkMode =>themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn){
    themeMode =isOn ?   ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}


class MyTheme{
  static final darkTheme =ThemeData(
    scaffoldBackgroundColor:Colors.black,
    primaryColor: Colors.white,
    colorScheme: ColorScheme.dark(),
    bottomAppBarColor: Color(0xFF282626),
    shadowColor: Colors.black.withOpacity(0.6),
    cardColor:  Color(0xFF282626),
    canvasColor: Color(0xFF7B7B7B),
    backgroundColor: Colors.amber.shade900,
    hintColor: Color(0xABC4BFBF),

  );
  static final lightTheme=ThemeData(
    scaffoldBackgroundColor: Color(0xFFE7E6E4),
    primaryColor:Colors.black,
    colorScheme: ColorScheme.light(),
    bottomAppBarColor: Color(0xFFBEB7AC),
    shadowColor: Colors.grey.withOpacity(0.2),
    cardColor: Color(0xABC4BFBF),
    canvasColor: Color(0xFFC4BFBF),
    backgroundColor: Colors.amber.shade900,
    hintColor: Color(0xFF282626),
  );
}
