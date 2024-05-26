import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase authentication instance
  late TextEditingController _nameController; // Controller for the name input field
  TextEditingController _passwordController = TextEditingController(); // Controller for the password input field
  bool _isPassObscure = true; // Toggle for password visibility

  void _showToast(String message) {
    // Function to show a toast notification
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(); // Initializing the name controller
    fetchUserData(); // Fetching user data on initialization
  }

  Future<void> fetchUserData() async {
    // Fetches the username from UserProvider and sets it to the _nameController
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUserName();
    _nameController.text = userProvider.userName;
  }

  Future<void> _updateProfile() async {
    // Function to update the user profile
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.w),
          ),
          backgroundColor: Theme.of(context).canvasColor,
          content: Row(
            children: [
              CircularProgressIndicator( color: Theme.of(context).backgroundColor,),
              SizedBox(width: 20),
              Text("Updating Profile...",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp
                ),),
            ],
          ),
        );
      },
    );

    try {
      User? user = _auth.currentUser; // Get the current user
      if (user != null) {
        if (_nameController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty &&
            _passwordController.text.length >= 5) {
          await user.updateProfile(displayName: _nameController.text); // Update user display name

          if (_passwordController.text.isNotEmpty) {
            await user.updatePassword(_passwordController.text); // Update user password
          }

          // Update Firestore database
          await FirebaseFirestore.instance
              .collection('Users')
              .where('Email', isEqualTo: user.email)
              .get()
              .then((querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              var docId = querySnapshot.docs[0].id;
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(docId)
                  .update({
                'UserName': _nameController.text,
              });
              Provider.of<UserProvider>(context, listen: false).fetchUserName(); // Refresh the username in the provider
            }
          });

          Navigator.pop(context); // Close the loading dialog
          _showToast('Profile updated successfully');
          Navigator.pop(context); // Pop the page from the navigation stack
        } else {
          Navigator.pop(context); // Close the loading dialog
          _showToast('Please fill all fields and ensure the password is at least 5 characters long');
        }
      }
    } catch (error) {
      Navigator.pop(context); // Close the loading dialog
      _showToast('Error updating profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 25.sp,
            color: Theme.of(context).primaryColor,
            fontFamily: "fonts/Raleway-Bold",
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColor,
            size: 5.h,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/profileScreen.jpeg"),
                ),
              ),
              child: Container(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 5.h),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Username',
                              color: Theme.of(context).primaryColor,
                              fontSize: 15.sp,
                            ),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              color: Theme.of(context).primaryColor,
                              fontSize: 15.sp,
                              isObscure: _isPassObscure,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPassObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).backgroundColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPassObscure = !_isPassObscure; // Toggle password visibility
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 3.h),
                            ElevatedButton(
                              onPressed: () {
                                _updateProfile(); // Trigger profile update
                              },
                              child: Text(
                                'Update your Profile',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).backgroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.w),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 2.h),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color color,
    required double fontSize,
    bool isObscure = false,
    IconButton? suffixIcon,
  }) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).backgroundColor, width: 2),
              borderRadius: BorderRadius.circular(8.w),
              color: Colors.grey.withOpacity(0.1),
            ),
            child: TextField(
              controller: controller,
              obscureText: isObscure, // Password obscurity toggle
              style: TextStyle(
                color: color,
                fontSize: fontSize,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: suffixIcon != null
                    ? GestureDetector(
                  onTap: suffixIcon.onPressed,
                  child: suffixIcon.icon, // Suffix icon for the text field
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
