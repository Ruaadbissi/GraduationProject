import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oktoast/oktoast.dart';

// This class manages the shopping list data
class ShoppingListProvider extends ChangeNotifier {
  final ShoppingListManager _shoppingListManager = ShoppingListManager(); // Instance of ShoppingListManager
  bool _isClearing = false; // Flag to indicate if the shopping list is being cleared

  // Getter for accessing the shopping list data
  List<Map<String, dynamic>> get shoppingList => _shoppingListManager.shoppingList;

  // Getter for checking if the shopping list is being cleared
  bool get isClearing => _isClearing;

  // Function to show toast messages
  void _showToast(String message) {
    showToast(
      message,
      duration: Duration(seconds: 2),
      position: ToastPosition.bottom,
      backgroundColor: Colors.amber.shade900,
      radius: 8.0,
      textStyle: TextStyle(fontSize: 16.0, color: Colors.black),
    );
  }

  // Constructor
  ShoppingListProvider() {
    // Initialize ShoppingListManager
    _shoppingListManager.init();

    // Listen for authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // Clear shopping list if user signs out or is a guest
        _shoppingListManager.clearList();
      } else {
        // Fetch shopping list data from Firestore if the user is logged in
        _fetchShoppingListFromFirestore(user.uid);
      }
    });
  }

  // Function to fetch shopping list data from Firestore
  Future<void> _fetchShoppingListFromFirestore(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).collection('shoppingList').doc('ingredient').get();
      final List<dynamic> ingredients = snapshot.get('ingredients');
      _shoppingListManager.clearList(); // Clear existing list before adding new data
      for (var ingredient in ingredients) {
        _shoppingListManager.addItem(ingredient['name'], ingredient['imageUrl']);
      }
      notifyListeners(); // Notify listeners about changes in shopping list
    } catch (error) {
      print('Error fetching shopping list from Firestore: $error');
    }
  }

  // Function to add an item to the shopping list
  void addItem(String name, String imageUrl) {
    // Check if the ingredient is already in the shopping list
    if (_shoppingListManager.shoppingList.any((item) => item['name'] == name)) {
      _showToast('Ingredient is already in the shopping list');
    } else {
      _shoppingListManager.addItem(name, imageUrl);
      // Save to Firestore
      _saveItemToFirestore(name);
      _showToast('Ingredient added to shopping list');
      notifyListeners(); // Notify listeners about changes in shopping list
    }
  }

  // Function to clear the shopping list
  void clearList() {
    _isClearing = true; // Set the flag to indicate that the list is being cleared
    _shoppingListManager.clearList(); // Clear local list
    // Clear Firestore collection
    _clearFirestore();
    _showToast('Shopping list cleared');
    _isClearing = false; // Reset the flag
    notifyListeners(); // Notify listeners about changes in shopping list
  }

  // Function to save an item to Firestore
  Future<void> _saveItemToFirestore(String name) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance.collection('Users').doc(userId).collection('shoppingList').doc('ingredient').update({
          'ingredients': FieldValue.arrayUnion([{'name': name, 'imageUrl': _shoppingListManager.shoppingList.firstWhere((item) => item['name'] == name)['imageUrl']}]),
        });
      } catch (error) {
        print('Error saving item to Firestore: $error');
      }
    }
  }

  // Function to remove an item from the shopping list
  void removeItem(String name) {
    _removeItemFromFirestore(name).then((_) {
      _shoppingListManager.removeItem(name); // Remove from local list
      _showToast('Ingredient removed from shopping list');
      notifyListeners(); // Notify listeners about changes in shopping list
    }).catchError((error) {
      print('Error removing item: $error');
      notifyListeners(); // Notify listeners about changes in shopping list
    });
  }

  // Function to remove an item from Firestore
  Future<void> _removeItemFromFirestore(String name) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final item = _shoppingListManager.shoppingList.firstWhere(
              (item) => item['name'] == name,
          orElse: () => {'name': '', 'imageUrl': ''}, // Default value when no match is found
        );
        final imageUrl = item['imageUrl'] ?? ''; // Get imageUrl from the local list
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('shoppingList')
            .doc('ingredient')
            .update({
          'ingredients': FieldValue.arrayRemove([
            {
              'name': name,
              'imageUrl': imageUrl
            }
          ]),
        });
      } catch (error) {
        print('Error removing item from Firestore: $error');
        throw error;
      }
    }
  }

  // Function to clear the Firestore collection
  Future<void> _clearFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance.collection('Users').doc(userId).collection('shoppingList').doc('ingredient').update({
          'ingredients': FieldValue.delete(),
        });
      } catch (error) {
        print('Error clearing Firestore collection: $error');
      }
    }
  }

}

// This class manages the local shopping list data using SharedPreferences
class ShoppingListManager {
  late SharedPreferences _prefs;
  final List<Map<String, dynamic>> _shoppingList = [];

  List<Map<String, dynamic>> get shoppingList => _shoppingList;

  static final ShoppingListManager _instance = ShoppingListManager._internal();

  factory ShoppingListManager() {
    return _instance;
  }

  ShoppingListManager._internal();

  // Initialize the ShoppingListManager
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load shopping list data from shared preferences
    _loadShoppingList();
  }

  // Function to add an item to the local shopping list
  void addItem(String name, String imageUrl) {
    _shoppingList.add({'name': name, 'imageUrl': imageUrl});
    _saveShoppingList();
  }

  // Function to remove an item from the local shopping list
  void removeItem(String name) {
    _shoppingList.removeWhere((item) => item['name'] == name);
    _saveShoppingList();
  }

  // Function to clear the local shopping list
  void clearList() {
    _shoppingList.clear();
    _saveShoppingList();
  }


  void _saveShoppingList() {
    final List<Map<String, dynamic>> encodedList = _shoppingList.map((item) {
      return {
        'name': item['name'],
        'imageUrl': item['imageUrl'],
      };
    }).toList();
    final List<String> encodedStringList = encodedList.map((item) => json.encode(item)).toList();
    _prefs.setStringList('shopping_list', encodedStringList);
  }

  void _loadShoppingList() {
    final List<String>? encodedList = _prefs.getStringList('shopping_list');
    if (encodedList != null) {
      _shoppingList.clear();
      for (String encodedItem in encodedList) {
        // Decode each item from the encoded string
        Map<String, dynamic> item = json.decode(encodedItem);
        _shoppingList.add(item);
      }
    }
  }
}
