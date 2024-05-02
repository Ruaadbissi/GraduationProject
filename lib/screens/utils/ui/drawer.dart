import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_cook1/screens/editProfile/editProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:magic_cook1/screens/login/login.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:magic_cook1/screens/utils/ui/Theme/themeSwitch.dart';
import 'package:magic_cook1/screens/utils/ui/rate/rate.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isPassObscure = true;


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).bottomAppBarColor,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children:  <Widget>[
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return _buildUserContainer(context, userProvider.userName);
              },
            ),
            Divider(),
            SizedBox(height: 20),
            SizedBox(height: 20),
            _buildMenuItem(
              context,
              Icons.nightlight_round,
              'Theme',
                  () {
                ThemeSwitch().showThemeDialog(
                  context,
                  Theme.of(context).brightness == Brightness.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.language,
              'Language',
                  () {
                // _showLanguageSelectionDialog();
              },
            ),
            _buildMenuItem(
              context,
              Icons.rate_review,
              'Rate Us',
                  () {
                _showRatingDialog(context);
              },
            ),
            _buildMenuItem(
              context,
              Icons.logout,
              'Log out',
                  () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserContainer(BuildContext context, String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            if (userName == "Guest User") {
              PersistentNavBarNavigator.pushNewScreen(context,
                screen:login(),
                withNavBar: false,
              );
            } else {
              _showPasswordVerificationDialog(context, userName);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  userName,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  userName == "Guest User" ? 'Log in now' : 'Edit Profile',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 2.0),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).primaryColor),
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showPasswordVerificationDialog(BuildContext context, String userName) {
    String enteredPassword = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Enter your Current Password to allow Modifications',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber.shade900, width: 2),
              borderRadius: BorderRadius.circular(30),
              color: Colors.grey.withOpacity(0.1),
            ),
            child: TextField(
              onChanged: (value) {
                enteredPassword = value;
              },
              obscureText: _isPassObscure,
              decoration: InputDecoration(
                hintText: 'Password',

              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    // Sign in with email and password
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: currentUser.email!,
                      password: enteredPassword,
                    );
                    // Password is correct, navigate to Edit Profile
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    );
                  }
                } catch (e) {
                  // Password is incorrect, display a toast message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Incorrect password')),
                  );
                }
              },
              child: Text(
                'Confirm',
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
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
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Theme.of(context).cardColor,
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Rate Us',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for (int i = 1; i <= 5; i++)
                          IconButton(
                            icon: _rating >= i
                                ? Icon(size: 30, Icons.star, color: Colors.amber.shade900)
                                : Icon(size: 30, Icons.star_border, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _rating = i;
                              });
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    rate(),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            // TODO: Handle submitting feedback (e.g., send to backend)
                            Navigator.of(context).pop();
                          },
                          child: Text('Submit', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
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

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Are you sure you want to logout and exit the app?',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut(); // Logout the user
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'); // Close the app
              },
              child: Text('Yes', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}
