import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/register/register.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:magic_cook1/screens/utils/ui/common_button.dart';
import 'package:magic_cook1/screens/utils/ui/common_textFeild.dart';
import 'package:magic_cook1/screens/utils/ui/navigation/navigationBar.dart';
import 'package:magic_cook1/screens/utils/ui/progress_hud.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

// Define a stateful widget for login
class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

// Define the state for the login widget
class _loginState extends State<login> with TickerProviderStateMixin {
  // Text controllers for email and password fields
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey(); // Global key for form validation
  FocusNode _emailFocus = FocusNode(); // Focus node for email field
  FocusNode _passwordFocus = FocusNode(); // Focus node for password field

  bool _isPassObscure = true; // State to toggle password visibility
  String? userName; // Placeholder for storing user name (if needed)

  // Function to show toast messages
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black, // Set background color to black
        body: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _key, // Assign global key to form
              child: Column(
                children: [
                  SizedBox(height: 8.h,), // Spacer
                  Image.asset(
                    "assets/logoBlack.png",
                    height: 23.h,
                    width: 25.h,
                  ), // Logo image
                  Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:  22.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ), // Login title
                  Container(
                    width: 48.h,
                    height: 30.h,
                    margin: EdgeInsets.symmetric(vertical: 3.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.w),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xF4000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ), // Container for email and password fields
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Email field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                            child: CustomTextField().createTextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              label: "Email Address",
                              radius: 5.w,
                              hint: "xxxx@gmail.com",
                              prefixIcon: Icon(Icons.email, color: Colors.black),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "This field is required";
                                }
                                if (v.length < 5) {
                                  return "Email must be greater than 5 characters";
                                }
                                if (v.contains(" ")) {
                                  return "Email must not include white space";
                                }
                                if (!isValidEmail(v)) {
                                  return "Please enter a valid email";
                                }
                                return null; // Validation successful
                              },
                            ),
                          ),
                          SizedBox(height: 3.h), // Spacer

                          // Password field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                            child: CustomTextField().createTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              isObscure: _isPassObscure,
                              label: "Password",
                              radius: 5.w,
                              prefixIcon: Icon(
                                Icons.key_rounded,
                                color: Colors.black,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPassObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPassObscure = !_isPassObscure; // Toggle password visibility
                                  });
                                },
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "This field is required";
                                }
                                if (v.length < 6) {
                                  return "Enter password at least 6 digits";
                                }
                                return null; // Validation successful
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h,), // Spacer

                  Container(
                    width: 50.w,
                    height: 8.h,
                    margin: EdgeInsets.only(top:  1.h),
                    child: CustomeButton(
                      title: 'Login',
                      onTap: () async {
                        if (_key.currentState!.validate()) {
                          // Show loading indicator
                          ProgressHud.shared.startLoading(context);

                          try {
                            // Attempt to sign in with email and password
                            UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            if (result.user != null) {
                              if (result.user!.emailVerified) {
                                // Fetch user name after login
                                await Provider.of<UserProvider>(context, listen: false).fetchUserName();
                                // Stop loading indicator
                                ProgressHud.shared.stopLoading();
                                // Navigate to home screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => navigationBar()),
                                );
                              } else {
                                // Show toast if email is not verified
                                _showToast('Your email is not verified');
                                // Stop loading indicator
                                ProgressHud.shared.stopLoading();
                              }
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              _showToast('Email is not registered');
                            } else if (e.code == 'wrong-password') {
                              _showToast('Wrong password');
                            } else {
                              _showToast(e.message!);
                            }
                            // Stop loading indicator on error
                            ProgressHud.shared.stopLoading();
                          } catch (e) {
                            _showToast(e.toString());
                            // Stop loading indicator on error
                            ProgressHud.shared.stopLoading();
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 5.h,), // Spacer
                  Positioned(
                    bottom: 1.h,
                    right: 1.w,
                    left: 1.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Not Registered yet?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 1),
                        TextButton(
                          onPressed: () {
                            // Navigate to the Register page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => register()),
                            );
                          },
                          child: Text(
                            'Register now',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to validate email format
  bool isValidEmail(String value) {
    String pattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }
}
