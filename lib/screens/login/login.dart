import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/homeScreen/homeScreen.dart';
import 'package:magic_cook1/screens/register/register.dart';
import 'package:magic_cook1/screens/utils/ui/common_button.dart';
import 'package:magic_cook1/screens/utils/ui/common_textFeild.dart';
import 'package:magic_cook1/screens/utils/ui/navigation/navigationBar.dart';
import 'package:magic_cook1/screens/utils/ui/progress_hud.dart';
import 'package:oktoast/oktoast.dart';



class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> with TickerProviderStateMixin {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  FocusNode _emailFocus = FocusNode();
  FocusNode _passwordFocus = FocusNode();

  bool _isPassObscure = true;


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
                SizedBox(height: 90,),
                Image.asset(
                  "assets/logoBlack.png",
                  height: 152,
                  width: 202,
                ),
                const Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 2,
                    letterSpacing: 6.40,
                  ),
                ),
                Container( // email and password place
                  width: 360,
                  height: 200,
                  margin: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
                        // Email field
                        Container(decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                          child: CustomTextField().createTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            label: "Email Address",
                            radius: 12,
                            hint: "xxxx@gmail.com",
                            prefixIcon: Icon(Icons.email, color: Colors.black),
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
                        SizedBox(height: 20),

                        // Password field
                        Container(decoration: BoxDecoration(
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
                              },),

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
                        Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                // Handle forget password action
                                print('Forget Password?');
                              },
                              child: Text(
                                'Forget Password?',
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  width: 200,
                  height: 50,
                  margin: EdgeInsets.only(top: 20),
                  child: CustomeButton(
                    title: 'Login',
                    onTap: ()async {
                      try {
                        UserCredential result = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        if (result.user != null) {
                          if (result.user!.emailVerified) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => navigationBar()),
                            );
                          } else {
                            showToast("your email is not verified",
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2)
                            );
                          }
                        }
                      }catch(e) {
                        if (e is FirebaseAuthException) {
                          showToast(e.message!,
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2)
                          );
                        }
                        showToast(e.toString(),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2)
                        );
                      }
                    },
                  ),
                ),

                SizedBox(height: 90,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not Registered yet?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 0.01,
                        letterSpacing: 3.20,
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
                          // Change the color as needed
                          fontSize: 18,
                          fontFamily: 'Inter',
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

}