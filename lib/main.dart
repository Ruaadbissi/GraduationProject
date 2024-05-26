import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart'; // Import the sizer package
import 'package:magic_cook1/screens/utils/helper/favorite/favProvider.dart';
import 'package:magic_cook1/screens/utils/helper/shoppingList/shoppingProvider.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:magic_cook1/firebase_options.dart';
import 'package:magic_cook1/l10n/LocalizationService.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
import 'package:magic_cook1/screens/splashScreen/splashScreen.dart';
import 'package:magic_cook1/screens/utils/ui/Theme/myTheme.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Get the current user ID
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  final userProvider = UserProvider(); // Create UserProvider instance
  await userProvider.fetchUserName(); // Fetch user name

  await ShoppingListManager().init();
  runApp(MyApp(userId: userId, userProvider: userProvider)); // Pass userProvider to MyApp
}

class MyApp extends StatefulWidget {
  final String userId;
  final UserProvider userProvider; // Add this line

  const MyApp({Key? key, required this.userId, required this.userProvider}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    await widget.userProvider.fetchUserName(); // Use userProvider passed from MyApp
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => LocalizationService()),
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => FavoritePlacesProvider()),
            ChangeNotifierProvider(create: (context) => ShoppingListProvider()),
            // Use the provided UserProvider instance instead of creating a new one
            ChangeNotifierProvider.value(value: widget.userProvider),
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

                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: _locale,
              ),
            );
          },
        );
      },
    );
  }
}
