import 'package:flutter/material.dart';

class registerTest extends StatefulWidget {
  const registerTest({Key? key}) : super(key: key);

  @override
  State<registerTest> createState() => _registerTestState();
}

class _registerTestState extends State<registerTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height*0.4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black12], // Adjust gradient colors as needed
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: Image.asset(
                "assets/logoBlack.png",
                height: 200,
                width: 200,
                fit: BoxFit.fill,
              ),
            ),
            Container(
              child: Center(
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
