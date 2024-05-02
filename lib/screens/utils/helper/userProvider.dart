import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  String _userName = "Guest User";

  String get userName => _userName;

  void setUserName(String newName) {
    _userName = newName;
    notifyListeners();
  }

  Future<void> fetchUserName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Users') // Assuming your collection is named 'Users'
          .where('Email', isEqualTo: user.email) // Filter by email
          .limit(1) // Limit to one document (should be unique)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic>? userData = snapshot.docs.first.data();
        if (userData != null && userData.containsKey('UserName')) {
          String? username = userData['UserName'] as String?;
          if (username != null && username.isNotEmpty) {
            setUserName(username);
          }
        }
      }
    }
  }
}
