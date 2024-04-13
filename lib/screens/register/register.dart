import 'dart:async';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                ),
                Image.asset(
                  "assets/logoBlack.png",
                  height: 156,
                  width: 202,
                ),
                const Text(
                  'Register',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w400,
                    height: 2,
                    letterSpacing: 6.40,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 350,
                    height: 360,
                    margin: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
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
                                borderRadius: BorderRadius.circular(10)),
                            child: CustomTextField().createTextField(
                              controller: _userNameController,
                              focusNode: _userFocus,
                              label: "User name",
                              radius: 12,
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
                          SizedBox(height: 15),

                          // Email field
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: CustomTextField().createTextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              label: "Email Address",
                              radius: 12,
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
                          SizedBox(height: 15),

                          // Password field
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: CustomTextField().createTextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              isObscure: _isPassObscure,
                              label: "Password",
                              radius: 12,
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
                                if (v.length < 6) {
                                  return "Enter password at least 6 digits";
                                }
                                return null; //هيك يعني الشغل صح
                              },
                            ),
                          ),
                          SizedBox(height: 15),

                          //confirm password field
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10)),
                            child: CustomTextField().createTextField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocus,
                              label: "Confirm Password",
                              prefixIcon: Icon(
                                Icons.key,
                                color: Colors.black,
                              ),
                              radius: 12,
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
                                  return "password not match";
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
                  width: 200,
                  height: 50,
                  margin: EdgeInsets.only(top: 20),
                  child: CustomeButton(
                      title: 'Register',
                      onTap: () async {
                        if (_key.currentState!.validate()) {
                          ProgressHud.shared.startLoading(
                              context); //تعطي اشارة انه البرنامج بحمل
                          try {
                            var acs = ActionCodeSettings(
                                url: 'https://www.example.com',
                                handleCodeInApp: true,
                                iOSBundleId: 'com.example.ios',
                                androidPackageName: 'com.example.android',
                                androidInstallApp: true,
                                androidMinimumVersion: '12');

                            UserCredential result = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            if (result.user != null) {
                              result.user!.sendEmailVerification(acs);
                              _saveDataToFirestore(result.user!.uid);
                              ProgressHud.shared.stopLoading();
                              showToast("please verify your email",
                                  backgroundColor: Colors.green,
                              duration: Duration(seconds: 2));

                            } else {
                              print("error");
                            }
                          } on FirebaseAuthException catch (e) {
                            print(e);
                            ProgressHud.shared.stopLoading();
                            showToast(e.message ?? "Error",
                                backgroundColor: Colors.red);
                            //todo call register
                          } catch (e) {
                            print(e);
                            ProgressHud.shared.stopLoading();
                            showToast(e.toString(),
                                backgroundColor: Colors.red);
                          }
                        }
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                // Row with "Not Registered yet?" and "Register now"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already Registered?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 0.01,
                        letterSpacing: 3.20,
                      ),
                    ),
                    SizedBox(width: 1),
                    TextButton(
                      onPressed: () {
                        // Navigate to the Login page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => login()),
                        );
                      },
                      child: Text(
                        'Login now',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          height: 0.01,
                          letterSpacing: 3.20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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

  void _saveDataToFirestore(String uid) {
    Map<String, dynamic> map ={};
    map.putIfAbsent("Email", () => _emailController.text);
    map.putIfAbsent("UserName", () => _userNameController.text);
    map.putIfAbsent("isVerify", () => false);
    map.putIfAbsent("UID", () => uid);
    FirebaseFirestore.instance.collection("Users").add(map);

  }
}
