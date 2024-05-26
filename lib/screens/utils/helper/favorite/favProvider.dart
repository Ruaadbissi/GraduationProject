import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Provider class for managing favorite recipes
class FavoritePlacesProvider extends ChangeNotifier {
  final FavoriteManager _favoriteManager = FavoriteManager(); // Instance of FavoriteManager for managing favorites
  bool _isClearing = false; // Flag for indicating whether favorites are being cleared

  // Getter for accessing the favorite list
  List<Map<String, dynamic>> get favoriteList => _favoriteManager.favoriteList;

  // Getter for accessing the clearing state
  bool get isClearing => _isClearing;

  // Constructor
  FavoritePlacesProvider() {
    // Initialize FavoriteManager
    _favoriteManager.init();

    // Listen for authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // Clear favorites if user signs out or is a guest
        _favoriteManager.clearList();
      } else {
        // Fetch favorites from Firestore if the user is logged in
        fetchFavoritesFromFirestore(user.uid);
      }
    });
  }

  // Method for fetching favorites from Firestore
  Future<void> fetchFavoritesFromFirestore(String userId) async {
    try {
      // Get favorites document from Firestore
      final snapshot = await FirebaseFirestore.instance.collection('Users').doc(userId).collection('favorites').doc('recipeIds').get();
      final List<dynamic> favorites = snapshot.get('recipeIds');

      // Clear existing list before adding new data
      _favoriteManager.clearList();
      // Add fetched favorites to the local list
      for (var favorite in favorites) {
        _favoriteManager.addItem(favorite['id'], favorite['name']);
      }
      // Notify listeners of changes
      notifyListeners();
    } catch (error) {
      print('Error fetching favorites from Firestore: $error');
    }
  }

  // Method for checking if a recipe with a given ID is a favorite
  bool isFavoriteById(String recipeId) {
    return _favoriteManager.isFavoriteById(recipeId);
  }

  // Method for toggling a recipe's favorite status
  Future<void> toggleFavoriteById(String recipeId, String recipeName) async {
    _favoriteManager.toggleItem(recipeId, recipeName);
    // Save to Firestore
    await _saveFavoritesToFirestore();
    // Notify listeners of changes
    notifyListeners();
  }

  // Method for saving favorites to Firestore
  Future<void> _saveFavoritesToFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final List<Map<String, dynamic>> favorites = _favoriteManager.favoriteList;
        // Save favorite recipes to Firestore
        await FirebaseFirestore.instance.collection('Users').doc(userId).collection('favorites').doc('recipeIds').set({
          'recipeIds': favorites.map((item) => {'id': item['id'], 'name': item['name']}).toList(),
        });
      } catch (error) {
        print('Error saving favorites to Firestore: $error');
      }
    }
  }
}

// Manager class for handling favorite recipes
class FavoriteManager {
  late SharedPreferences _prefs;
  final List<Map<String, dynamic>> _favoriteList = []; // List to store favorite recipes

  // Getter for accessing the favorite list
  List<Map<String, dynamic>> get favoriteList => _favoriteList;

  // Singleton instance
  static final FavoriteManager _instance = FavoriteManager._internal();

  // Factory constructor for getting the singleton instance
  factory FavoriteManager() {
    return _instance;
  }

  // Internal constructor
  FavoriteManager._internal();

  // Method for initializing SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load favorites data from shared preferences
    _loadFavorites();
  }

  // Method for adding a favorite recipe
  void addItem(String id, String name) {
    _favoriteList.add({'id': id, 'name': name});
    _saveFavorites();
  }

  // Method for checking if a recipe with a given ID is a favorite
  bool isFavoriteById(String recipeId) {
    return _favoriteList.any((item) => item['id'] == recipeId);
  }

  // Method for toggling a recipe's favorite status
  void toggleItem(String id, String name) {
    if (_favoriteList.any((item) => item['id'] == id)) {
      _favoriteList.removeWhere((item) => item['id'] == id);
    } else {
      _favoriteList.add({'id': id, 'name': name});
    }
    _saveFavorites();
  }

  // Method for clearing the list of favorite recipes
  void clearList() {
    _favoriteList.clear();
    _saveFavorites();
  }

  // Method for saving the list of favorite recipes to SharedPreferences
  void _saveFavorites() {
    final List<String> encodedList = _favoriteList.map((item) => json.encode(item)).toList();
    _prefs.setStringList('favorite_list', encodedList);
  }

  // Method for loading the list of favorite recipes from SharedPreferences
  void _loadFavorites() {
    final List<String>? encodedList = _prefs.getStringList('favorite_list');
    if (encodedList != null) {
      _favoriteList.clear();
      for (String encodedItem in encodedList) {
        // Decode each item from the encoded string
        Map<String, dynamic> item = json.decode(encodedItem);
        _favoriteList.add(item);
      }
    }
  }
}
