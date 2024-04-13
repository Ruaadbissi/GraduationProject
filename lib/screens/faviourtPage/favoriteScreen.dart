import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
import 'package:magic_cook1/screens/detailsScreen/detailsScreen.dart';
import 'package:magic_cook1/screens/utils/helper/favProvider.dart';
import 'package:magic_cook1/screens/utils/helper/model.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.amber.shade900,
            size: 40,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.favorite,
          style: TextStyle(
            fontSize: 35,
            color: Theme.of(context).primaryColor,
            fontFamily: "fonts/Raleway-Bold",
          ),
        ),
      ),
      body: Consumer<FavoritePlacesProvider>(
        builder: (context, favoriteProvider, child) {
          List<Map<String, dynamic>> favoritePlaces =
          Provider.of<FavoritePlacesProvider>(context)
              .favoritePlaces
              .cast<Map<String, dynamic>>();
          return ListView.builder(
            itemCount: favoritePlaces.length,
            itemBuilder: (context, index) {
              final place = favoritePlaces[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => detailsScreen(
                        recipeName: place['strMeal'],
                        categoryName: place['strCategory'],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(8),
                  width: 340,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: Image.network(place['strMealThumb']),
                          ),
                          SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place['strMeal'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                place['strArea'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          favoriteProvider.toggleFavorite(place as placeModel);
                        },
                        child: Icon(
                          favoriteProvider.isFavorite(place as placeModel)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favoriteProvider.isFavorite(place as placeModel)
                              ? Colors.amber.shade900
                              : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
