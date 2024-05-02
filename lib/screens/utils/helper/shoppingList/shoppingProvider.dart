import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/utils/helper/shoppingList/shopping_list_manager.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ShoppingListProvider extends ChangeNotifier {
  final ShoppingListManager _shoppingListManager = ShoppingListManager();
  bool _isClearing = false;

  List<Map<String, dynamic>> get shoppingList => _shoppingListManager.shoppingList;

  bool get isClearing => _isClearing;

  ShoppingListProvider() {
    // Initialize ShoppingListManager
    _shoppingListManager.init();
  }

  void addItem(String name, String imageUrl) {
    // Check if the ingredient is already in the shopping list
    if (_shoppingListManager.shoppingList.any((item) => item['name'] == name)) {
      showToast('Ingredient is already in the shopping list', position: ToastPosition.bottom);
    } else {
      _shoppingListManager.addItem(name, imageUrl);
      showToast('Ingredient added to shopping list', position: ToastPosition.bottom);
      notifyListeners();
    }
  }

  void removeItem(String name) {
    _shoppingListManager.removeItem(name);
    notifyListeners();
  }

  void clearList() {
    _isClearing = true;
    _shoppingListManager.clearList();
    _isClearing = false;
    notifyListeners();
  }
}

