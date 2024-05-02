import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:magic_cook1/firebase_options.dart';
import 'package:magic_cook1/l10n/LocalizationService.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
import 'package:magic_cook1/screens/splashScreen/splashScreen.dart';
import 'package:magic_cook1/screens/utils/helper/favProvider.dart';
import 'package:magic_cook1/screens/utils/helper/shoppingList/shoppingProvider.dart';
import 'package:magic_cook1/screens/utils/helper/shoppingList/shopping_list_manager.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:magic_cook1/screens/utils/ui/Theme/myTheme.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await ShoppingListManager().init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale neLocale){
    _MyAppState? state =context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(neLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  setLocale(Locale locale){
    setState(() {
      _locale =locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocalizationService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => FavoritePlacesProvider()),
        ChangeNotifierProvider(create: (context) => ShoppingListProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return OKToast(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: MyTheme.lightTheme,
            darkTheme: MyTheme.darkTheme,
            home: splashScreen(),

            localizationsDelegates:AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: _locale,
          ),
        );
      },
    );
  }
}
