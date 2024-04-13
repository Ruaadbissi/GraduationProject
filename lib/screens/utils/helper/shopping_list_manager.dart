import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListManager {
  static final ShoppingListManager _instance = ShoppingListManager._internal();
  late SharedPreferences _prefs;

  factory ShoppingListManager() {
    return _instance;
  }

  ShoppingListManager._internal() {
    init();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<String> get shoppingList {
    return _prefs.getStringList('shopping_list') ?? [];
  }

  void addItem(String item, String recipeName) {
    List<String> list = shoppingList;
    String itemWithRecipe = '$item ($recipeName)';
    if (!list.contains(itemWithRecipe)) { // Check if the item is not already in the list
      list.add(itemWithRecipe);
      _prefs.setStringList('shopping_list', list);
    }
  }

  void removeItem(String item) {
    List<String> list = shoppingList;
    list.remove(item);
    _prefs.setStringList('shopping_list', list);
  }

  void clearList() {
    _prefs.remove('shopping_list');
  }
}
