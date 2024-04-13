import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomeButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  //final double?  width;
  const CustomeButton({super.key, required this.title, required this.onTap} );


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //width: width??40.w,
      child: ElevatedButton(style:  ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )),

          onPressed: (){
        FocusManager.instance.primaryFocus!.unfocus();
        onTap.call();
          },
          child: Text(
            title,
            style: TextStyle( color: Colors.white,
              fontSize: 20,
              fontFamily: 'Inter',

            ),
          )),
    );
  }
}