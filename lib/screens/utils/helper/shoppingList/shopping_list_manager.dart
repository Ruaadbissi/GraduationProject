import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListManager {
  late SharedPreferences _prefs;
  final List<Map<String, dynamic>> _shoppingList = [];

  List<Map<String, dynamic>> get shoppingList => _shoppingList;

  static final ShoppingListManager _instance = ShoppingListManager._internal();

  factory ShoppingListManager() {
    return _instance;
  }

  ShoppingListManager._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load shopping list data from shared preferences
    _loadShoppingList();
  }

  void addItem(String name, String imageUrl) {
    _shoppingList.add({'name': name, 'imageUrl': imageUrl});
    _saveShoppingList();
  }

  void removeItem(String name) {
    _shoppingList.removeWhere((item) => item['name'] == name);
    _saveShoppingList();
  }

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
    final List<String> encodedStringList = encodedList.map((item) =>
        json.encode(item)).toList();
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
    }}
// void _loadShoppingList() {
//   final List<String>? encodedList = _prefs.getStringList('shopping_list');
//   if (encodedList != null) {
//     _shoppingList.clear();
//     for (String encodedItem in encodedList) {
//       try {
//         // Decode each item from the encoded string
//         Map<String, dynamic> item = json.decode(encodedItem);
//         _shoppingList.add(item);
//       } catch (e) {
//         print('Error decoding item: $e');
//         // Handle the error gracefully, such as skipping the item or logging the error
//       }
//     }
//   }
// }

}

