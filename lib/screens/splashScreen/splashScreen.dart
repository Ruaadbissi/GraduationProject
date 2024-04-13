import 'dart:async';
import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/login/login.dart';
import 'package:magic_cook1/screens/register/register.dart';
import 'package:magic_cook1/screens/slider/slider.dart';


class splashScreen extends StatefulWidget {
  @override
  _splashScreenState createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Timer(
     const Duration(seconds: 4),
          () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => sliderScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration:const Duration(seconds: 5),
          curve: Curves.easeInOut,
          onEnd: () {
            setState(() {
              _visible = false;
            });
          },
          child: Image.asset(
            'assets/magic.gif',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }
}
