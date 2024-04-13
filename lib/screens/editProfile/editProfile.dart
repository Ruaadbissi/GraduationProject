import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
//import 'package:magic_cook1/screens/setting/SettingButton.dart';

class editProfile extends StatefulWidget {
  const editProfile({Key? key}) : super(key: key);

  @override
  State<editProfile> createState() => _editProfileState();
}

class _editProfileState extends State<editProfile> {
  File? _imageFile;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isPassObscure = true;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   leading: IconButton(
      //     icon: Icon(
      //       Icons.arrow_back,
      //       color: Colors.amber.shade900 ,
      //       size: 40,
      //     ),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   title:  Text(
      //     'Edit Profile',
      //     style: TextStyle(
      //       fontSize: 35,
      //       color: Theme.of(context).primaryColor,
      //       fontFamily: "Raleway-Bold",
      //     ),
      //   ),
      // ),
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
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon:  Icon(
                                  Icons.arrow_back,
                                  color: Colors.amber.shade900,
                                  size: 40,
                                ),
                                onPressed: () {
                                   Navigator.pop(context);
                                },
                              ),
                              SizedBox(width: 10,),
                              Text(
                                AppLocalizations.of(context)!.edit_profile,
                                style: TextStyle(
                                    fontSize: 35,
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: "fonts/Raleway-Bold"),
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.amber.shade900 , width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : null,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber.shade900 ,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt),
                                    iconSize: 30,
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () {
                                      _showImagePickerDialog();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildTextField(
                            controller: _nameController,
                            label:AppLocalizations.of(context)!.username,
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                          ),
                          _buildTextField(
                            controller: _emailController,
                            label:AppLocalizations.of(context)!.email,
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                          ),
                          _buildTextField(
                            controller: _passwordController,
                            label:AppLocalizations.of(context)!.password,
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _isPassObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.amber.shade900 ),
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
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => SettingButton()),
                            //   );
                             },
                            child: Text(
                              AppLocalizations.of(context)!.confirm,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.amber.shade900 ,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 10),
                            ),
                          ),
                        ],
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
                border: Border.all(color: Colors.amber.shade900 , width: 2),
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey.withOpacity(0.1)),
            child: TextField(
              controller: controller,
              obscureText: label.toLowerCase() == 'password' ? true : false,
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

  Future<void> _showImagePickerDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            title: Text(
              "Choose Image Source",
              style: TextStyle(color: Theme.of(context).primaryColor,),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading:  Icon(
                    Icons.photo_library,
                    color: Theme.of(context).primaryColor,
                  ),
                  title:  Text(
                    "Gallery",
                    style: TextStyle(color: Theme.of(context).primaryColor,),
                  ),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading:  Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).primaryColor,
                  ),
                  title:  Text(
                    "Camera",
                    style: TextStyle(color: Theme.of(context).primaryColor,),
                  ),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
