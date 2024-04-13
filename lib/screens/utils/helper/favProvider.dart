import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/utils/helper/model.dart';
import 'package:provider/provider.dart';


class FavoritePlacesProvider extends ChangeNotifier {
  List<placeModel> _favoritePlaces = [];

  List<placeModel> get favoritePlaces => _favoritePlaces;

  // Method to toggle favorite status of a placeModel
  void toggleFavorite(placeModel model) {
    if (_favoritePlaces.contains(model)) {
      _favoritePlaces.remove(model);
    } else {
      _favoritePlaces.add(model);
    }
    // Notify listeners about the change
    notifyListeners();
  }

  // Method to check if a placeModel is a favorite
  bool isFavorite(placeModel model) {
    return _favoritePlaces.contains(model);
  }
}