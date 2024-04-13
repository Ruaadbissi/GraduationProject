import 'package:flutter/material.dart';

class CustomTextField {
  static final CustomTextField _shared = CustomTextField._private();

  factory CustomTextField() => _shared;

  CustomTextField._private();

  Widget createTextField(
      {required TextEditingController controller,
        FocusNode? focusNode,
        bool isObscure = false,
        Widget? suffixIcon,
        Widget? prefixIcon,
        required String label,
        String? hint,
        FormFieldValidator<String>? validator,
        double radius = 8}) {
    return TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isObscure,
        validator: validator,
        style: TextStyle(height: 0.2,color:Colors.black, fontSize: 18,),
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          label: Text(
            label,
            style: TextStyle(color:Colors.black, fontSize: 18,),
          ),
          hintText: hint,

          border: _getBorderStyle(radius),
          focusedBorder: _getBorderStyle(radius),
          enabledBorder: _getBorderStyle(radius),
          disabledBorder: _getBorderStyle(radius),
          errorBorder: _getBorderStyle(radius), // Border color for error state
          focusedErrorBorder: _getBorderStyle(radius), // Border color for error state when focused
        ) );}

  OutlineInputBorder _getBorderStyle(radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: Colors.black87,
        width: 1,
      ),
    );
  }}
