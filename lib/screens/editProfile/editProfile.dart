import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController _nameController;
  TextEditingController _passwordController = TextEditingController();
  bool _isPassObscure = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUserName();
    _nameController.text = userProvider.userName;
  }

  Future<void> _updateProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (_nameController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty &&
            _passwordController.text.length >= 5) {
          await user.updateProfile(displayName: _nameController.text);

          // Update password if provided
          if (_passwordController.text.isNotEmpty) {
            await user.updatePassword(_passwordController.text);
          }

          // Update Firestore document with new data based on user's email
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
              // Refresh user data in the CustomDrawer
              Provider.of<UserProvider>(context, listen: false).fetchUserName();
            }
          });

          // Handle success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Pop the page from the navigation stack
          Navigator.pop(context);
        } else {
          // Handle incomplete fields or invalid password
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please fill all fields and ensure the password is at least 5 characters long'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $error'),
          backgroundColor: Colors.red,
        ),
      );
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
            fontSize: 35,
            color: Theme.of(context).primaryColor,
            fontFamily: "fonts/Raleway-Bold",
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColor,
            size: 40,
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
                            SizedBox(height: 25),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Username',
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                            ),
                            _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              color: Theme.of(context).primaryColor,
                              fontSize: 20,
                              isObscure: _isPassObscure,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPassObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.amber.shade900,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPassObscure = !_isPassObscure;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: () {
                                _updateProfile();
                              },
                              child: Text(
                                'Update your Profile',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.amber.shade900,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
              border: Border.all(color: Colors.amber.shade900, width: 2),
              borderRadius: BorderRadius.circular(30),
              color: Colors.grey.withOpacity(0.1),
            ),
            child: TextField(
              controller: controller,
              obscureText: isObscure,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIcon: suffixIcon != null
                    ? GestureDetector(
                  onTap: suffixIcon.onPressed,
                  child: suffixIcon.icon,
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
