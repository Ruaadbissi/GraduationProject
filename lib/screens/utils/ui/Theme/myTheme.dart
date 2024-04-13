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
    cardColor: Color(0xFF373535),
    canvasColor: Color(0xFF7B7B7B),
  );
  static final lightTheme=ThemeData(
    scaffoldBackgroundColor:Colors.white,
    primaryColor: Colors.black,
    colorScheme: ColorScheme.light(),
    bottomAppBarColor: Color(0xFF504E4E),
    shadowColor: Colors.grey.withOpacity(0.5),
    cardColor: Colors.grey,
    canvasColor: Color(0xFF282626),

  );
}
