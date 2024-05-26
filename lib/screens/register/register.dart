import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/login/login.dart';
import 'package:magic_cook1/screens/utils/ui/common_button.dart';
import 'package:magic_cook1/screens/utils/ui/common_textFeild.dart';
import 'package:magic_cook1/screens/utils/ui/progress_hud.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> with TickerProviderStateMixin {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  FocusNode _emailFocus = FocusNode();
  FocusNode _userFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();
  FocusNode _confirmPasswordFocus = FocusNode();

  bool _isPassObscure = true;
  bool _isPassObscureConfirm = true;

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
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _key,
              child: Column(
                children: [
                  SizedBox(
                    height:4.h,
                  ),
                  Image.asset(
                    "assets/logoBlack.png",
                    height: 23.h,
                    width: 25.h,
                  ),
                  Text(
                    'Register',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.all(2.w),
                    child: Container(
                      width: 48.h,
                      height: 45.h,
                      margin: EdgeInsets.symmetric(vertical: 1.w),
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
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //user name
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5.w)),
                              child: CustomTextField().createTextField(
                                controller: _userNameController,
                                focusNode: _userFocus,
                                label: "User name",
                                radius: 5.w,
                                prefixIcon:
                                Icon(Icons.person, color: Colors.black),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  if (value.length < 5) {
                                    return "user name must greater then 5 chars";
                                  }
                                  if (value.contains(" ")) {
                                    return "user name must not include white space";
                                  }
                                  return null; // Return null if the input is valid
                                },
                              ),
                            ),
                            SizedBox(height: 2.h),

                            // Email field
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5.w)),
                              child: CustomTextField().createTextField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                label: "Email Address",
                                radius: 5.w,
                                prefixIcon:
                                Icon(Icons.email, color: Colors.black),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "this field is required";
                                  }
                                  if (v.length < 5) {
                                    return "email must greater then 5 chars";
                                  }
                                  if (v.contains(" ")) {
                                    return "email must not include white space";
                                  }
                                  if (!isValidEmail(v)) {
                                    return "please enter valid email";
                                  }
                                  return null; //هيك يعني الشغل صح
                                },
                              ),
                            ),
                            SizedBox(height: 2.h),

                            // Password field
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5.w)),
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
                                      color: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      _isPassObscure = !_isPassObscure;
                                    });
                                  },
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "this field is required";
                                  }
                                  return null; //هيك يعني الشغل صح
                                },
                              ),
                            ),
                            SizedBox(height: 2.h),

                            //confirm password field
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5.w)),
                              child: CustomTextField().createTextField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocus,
                                label: "Confirm Password",
                                prefixIcon: Icon(
                                  Icons.key,
                                  color: Colors.black,
                                ),
                                radius: 5.w,
                                isObscure: _isPassObscureConfirm,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                      _isPassObscureConfirm
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      _isPassObscureConfirm =
                                      !_isPassObscureConfirm;
                                    });
                                  },
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return "this field is required";
                                  }
                                  if (v != _passwordController.text) {
                                    return "password didn't match";
                                  }
                                  return null; //هيك يعني الشغل صح
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                      width: 50.w,
                      height: 8.h,
                      margin: EdgeInsets.only(top: 1.h),
                      child: CustomeButton(
                          title: 'Register',
                          onTap: () async {
                            if (_key.currentState!.validate()) {
                              ProgressHud.shared.startLoading(context); //تعطي اشارة انه البرنامج بحمل
                              try {
                                var actionCodeSettings = ActionCodeSettings(
                                  url: 'https://www.example.com', // URL to redirect to after email verification
                                  handleCodeInApp: true, // Open the app when the user clicks the link in the email
                                  iOSBundleId: 'com.example.ios', // iOS bundle ID
                                  androidPackageName: 'com.example.android', // Android package name
                                  androidInstallApp: true, // Install the app if it's not already installed
                                  androidMinimumVersion: '12', // Minimum Android version required
                                  // Customize other parameters as needed
                                );

                                UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );

                                if (result.user != null) {
                                  // Send email verification
                                  await result.user!.sendEmailVerification(actionCodeSettings);

                                  // Save user data to Firestore
                                  _saveDataToFirestore(result.user!.uid);

                                  // Display a toast message to inform the user
                                  _showToast('A verification email has been sent to ${_emailController.text}. Please check your inbox.');
                                  Navigator.of(context).pop();
                                } else {
                                  print("error");
                                }
                              } on FirebaseAuthException catch (e) {
                                print(e);
                                ProgressHud.shared.stopLoading();
                                _showToast(e.message ?? "Error");
                              } catch (e) {
                                print(e);
                                ProgressHud.shared.stopLoading();
                                _showToast(e.toString());
                                showToastWidget(Container(
                                  height: 50.h,
                                  width: 100.w,
                                  child: Text(e.toString()),
                                ));
                              }

                            }
                          })),
                  Positioned(
                    bottom: 1.h,
                    right: 1.w,
                    left: 1.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already Registered?',
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
                            // Navigate to the login page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => login()),
                            );
                          },
                          child: Text(
                            'Login now',
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

  bool isValidEmail(String value) {
    String pattern = r'^[\w-]+(\.[w-]+)*@[\w-]+(\.[\w-]+)+$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  void _saveDataToFirestore(String uid) async {
    Map<String, dynamic> userData = {
      "UserName": _userNameController.text,
      "Email": _emailController.text,
      "isVerify": true,
      "UID": uid,
    };

    try {
      // Create user document
      await FirebaseFirestore.instance.collection("Users").doc(uid).set(userData);

      // Create subcollection for favorites
      await FirebaseFirestore.instance.collection("Users").doc(uid).collection("favorites").doc('recipeIds').set({
        'recipeIds': [], // Initialize an empty list to store recipe IDs
      });

      // Create subcollection for shopping list
      await FirebaseFirestore.instance.collection("Users").doc(uid).collection("shoppingList").doc('ingredient').set({
        'ingredients': [], // Initialize an empty list to store ingredients
      });

      // Create subcollection for meal planning
      await FirebaseFirestore.instance.collection("Users").doc(uid).collection("mealPlanning").doc('plans').set({
        'recipes': {}, // Initialize an empty map to store meal plans
      });
    } catch (error) {
      print("Error saving data to Firestore: $error");
    }
  }
}
