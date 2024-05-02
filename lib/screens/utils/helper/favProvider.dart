import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePlacesProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  Set<String> _favoriteRecipeIds = {};

  FavoritePlacesProvider() {
    _initPrefs();
  }


  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _favoriteRecipeIds = (_prefs.getStringList('favoriteRecipeIds') ?? []).toSet(); // Load saved favorite recipe IDs
    notifyListeners();
  }

  Set<String> get favoriteRecipeIds => _favoriteRecipeIds;


  void toggleFavoriteById(String recipeId) {
    // Ensure recipeId is not null
    assert(recipeId != null);


    if (_favoriteRecipeIds.contains(recipeId)) {
      _favoriteRecipeIds.remove(recipeId);
    } else {
      _favoriteRecipeIds.add(recipeId);
    }


    _prefs.setStringList('favoriteRecipeIds', _favoriteRecipeIds.toList());

    notifyListeners();
  }

  bool isFavoriteById(String recipeId) {
    return _favoriteRecipeIds.contains(recipeId);
  }
}
