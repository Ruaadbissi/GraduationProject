import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
import 'package:magic_cook1/screens/utils/ui/Theme/myTheme.dart';
import 'package:provider/provider.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({Key? key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeMode = themeProvider.themeMode;

    return GestureDetector(
      onTap: () {
        showThemeDialog(context, themeMode);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 120,
        height: 68,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: themeMode == ThemeMode.dark ? Colors.amber[900] : Colors.grey[400],
        ),
        child: Stack(
          children: [
            Positioned(
              left: themeMode == ThemeMode.dark ? 50 : 0,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: themeMode == ThemeMode.dark
                    ? Icon(Icons.wb_sunny, color: Colors.amber[900])
                    : Icon(Icons.nightlight_round, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showThemeDialog(BuildContext context, ThemeMode themeMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                AppLocalizations.of(context)!.sel_theme,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      final provider = Provider.of<ThemeProvider>(context, listen: false);
                      provider.toggleTheme(themeMode == ThemeMode.light); // Toggle theme
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: themeMode == ThemeMode.dark ? Colors.grey[700] : Colors.amber[900],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: themeMode == ThemeMode.dark ? 0 : 50,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: themeMode == ThemeMode.dark
                                  ? Icon(Icons.nightlight_round, color: Colors.black)
                                  : Icon(Icons.wb_sunny, color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
