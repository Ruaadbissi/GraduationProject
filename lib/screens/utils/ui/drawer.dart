import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_cook1/screens/editProfile/editProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:magic_cook1/screens/login/login.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:magic_cook1/screens/utils/ui/Theme/themeSwitch.dart';
import 'package:oktoast/oktoast.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CustomDrawer extends StatefulWidget {
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isPassObscure = true;

  void _showToast(String message) {
    showToast(
      message,
      duration: Duration(seconds: 2),
      position: ToastPosition.bottom,
      backgroundColor: Colors.amber.shade900,
      radius: 8.0,
      textStyle: TextStyle(fontSize: 16.0, color: Colors.black),
    );
  }

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
            Divider(color:Theme.of(context).primaryColor, ),
            SizedBox(height: 3.h),
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
      padding:  EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.w),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.w),
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
                padding:  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                child: Text(
                  userName,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 20.sp,
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                child: Text(
                  userName == "Guest User" ? 'Log in now' : 'Edit Profile',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.sp,
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
      padding:  EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.w),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5.w),
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
            padding:  EdgeInsets.only(top: 1.w),
            child: Text(
              title,
              style: TextStyle(fontSize: 15.sp, color: Theme.of(context).primaryColor),
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
            borderRadius: BorderRadius.circular(5.w),
          ),
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(
            'Enter your Current Password to allow Modifications',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp
            ),
          ),
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).backgroundColor, width: 2),
              borderRadius: BorderRadius.circular(8.w),
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
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10.sp),
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
                  _showToast('Incorrect password');

                }
              },
              child: Text(
                'Confirm',
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10.sp),
              ),
            ),
          ],
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
            borderRadius: BorderRadius.circular(5.w),
          ),
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(
            'Are you sure you want to logout and exit the app?',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                  'No',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10.sp)
              ),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut(); // Logout the user
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'); // Close the app
              },
              child: Text(
                  'Yes',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10.sp)
              ),
            ),
          ],
        );
      },
    );
  }
}
