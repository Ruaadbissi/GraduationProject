import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/utils/helper/shopping_list_manager.dart';

class ShoppingListProvider extends ChangeNotifier {
  final ShoppingListManager _shoppingListManager = ShoppingListManager();
  bool _isClearing = false; // Add isClearing state

  List<String> get shoppingList => _shoppingListManager.shoppingList;

  bool get isClearing => _isClearing; // Getter for isClearing state

  void addItem(String item, String recipeName) {
    _shoppingListManager.addItem(item, recipeName);
    notifyListeners();
  }

  void removeItem(String item) {
    _shoppingListManager.removeItem(item);
    notifyListeners();
  }

  void clearList() {
    _isClearing = true; // Set isClearing to true before clearing the list
    _shoppingListManager.clearList();
    _isClearing = false; // Reset isClearing after clearing the list
    notifyListeners();
  }
}
