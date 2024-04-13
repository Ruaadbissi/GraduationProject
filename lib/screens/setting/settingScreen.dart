import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/LocalizationService.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
import 'package:magic_cook1/main.dart';
import 'package:magic_cook1/screens/editProfile/editProfile.dart';
import 'package:magic_cook1/screens/utils/ui/Theme/themeSwitch.dart';
import 'package:magic_cook1/screens/utils/ui/rate/rate_Dark.dart';
import 'package:provider/provider.dart';

class SettingButton extends StatefulWidget {
  @override
  _SettingButtonState createState() => _SettingButtonState();
}

class _SettingButtonState extends State<SettingButton> {
  bool _isMenuOpen = false;
  bool _isLanguageTileOpen = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
        builder: (context, localizationService, _) {
      return Container(
          padding: const EdgeInsets.only(bottom: 10),
          width: MediaQuery
              .of(context)
              .size
              .width * 0.8,
          child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.only(right: 15),
                      width: 45,
                      height: 42,
                      child: Icon(
                        Icons.settings,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.setting,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        height: 1.2125,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(50),
                      side: BorderSide(color: Theme
                          .of(context)
                          .primaryColor, width: 2)
                  ),
                  leading: Icon(
                    _isMenuOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.options,
                    style: TextStyle(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  backgroundColor: Theme
                      .of(context)
                      .shadowColor,
                  trailing: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.transparent,
                  ),
                  onExpansionChanged: (bool expanding) {
                    setState(() {
                      _isMenuOpen = expanding;
                    });
                  },
                  children: [
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.edit_profile,
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                      ),
                      leading: Icon(
                        Icons.edit,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ),
                      onTap: () {
                        _handleOptionSelected('Edit Profile');
                      },
                    ),
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.theme,
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                      ),
                      leading: Icon(
                        Icons.light_mode,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ),
                      onTap: () {
                        _handleOptionSelected('Theme');
                      },
                    ),
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.language,
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                      ),
                      leading: Icon(
                        Icons.language,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ),
                      onTap: () {
                        changeLanguageDialog(context);
                      },
                    ),


                    ListTile(
                      title: Text(
                        AppLocalizations.of(context)!.rate_us,
                        style: TextStyle(
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                      ),
                      leading: Icon(
                        Icons.rate_review,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ),
                      onTap: () {
                        _handleOptionSelected('Rate Us');
                      },
                    ),
                  ],
                ),
              ]
          )
      );
        }
    );
  }

  Future<dynamic> changeLanguageDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          backgroundColor: Color(0xFF373535),
          title: Text(
            AppLocalizations.of(context)!.selectLanguage,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.en,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  MyApp.setLocale(context, Locale('en'));
                },
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.ar,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  MyApp.setLocale(context, Locale('ar'));
                },
              ),
            ],
          ),
        );
      },
    );
    }

  void _handleOptionSelected(String value) {
    setState(() {
      _isLanguageTileOpen = value == 'Language' ? !_isLanguageTileOpen : false;
    });

    switch (value) {
      case 'Edit Profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => editProfile()),
        );
        break;
      case 'Theme':
        ThemeSwitch().showThemeDialog(
            context,
            Theme
                .of(context)
                .brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light);
        break;
      case 'Language':
        break;
      case 'Rate Us':
        _showRatingDialog(context);
        break;
    }
  }
}


void _showRatingDialog(BuildContext context) {
  int _rating = 0; // Default rating

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            backgroundColor: Color(0xFF373535),
            // Change background color to grey
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                      child: Text(
                          AppLocalizations.of(context)!.rate_us,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold))),
                  SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i = 1; i <= 5; i++)
                        IconButton(
                          icon: _rating >= i
                              ? Icon(
                              size: 30,
                              Icons.star,
                              color: Colors.amber.shade900)
                              : Icon(
                              size: 30,
                              Icons.star_border,
                              color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _rating = i;
                            });
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  rateDark(),

                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          // TODO: Handle submitting feedback (e.g., send to backend)
                          Navigator.of(context).pop();
                        },
                        child: Text(
                            AppLocalizations.of(context)!.submit,
                            style:
                            TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                            AppLocalizations.of(context)!.cancle,
                            style:
                            TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
