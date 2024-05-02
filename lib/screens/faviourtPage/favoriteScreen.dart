import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
import 'package:magic_cook1/screens/detailsScreen/detailsScreen.dart';

import 'package:magic_cook1/screens/utils/helper/favProvider.dart';
import 'package:magic_cook1/screens/utils/helper/model.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';



class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          final List<String> favoriteIds = favoriteProvider.favoriteRecipeIds.toList();
          return ListView.builder(
            itemCount: favoriteIds.length,
            itemBuilder: (context, index) {
              final String id = favoriteIds[index];
              return FutureBuilder<Map<String, dynamic>?>(
                future: _fetchRecipeById(id),
                builder: (context, snapshot) {

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.hasData) {
                    final recipe = snapshot.data!;
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailsPage(
                              recipeName: recipe['strMeal'],
                              categoryName: recipe['strCategory'],
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
                                  width: 10,
                                  height: 60,),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50), // Apply border radius to make the image rounded
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: Offset(0, 2), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50), // Clip the image to the rounded border
                                    child: Image.network(
                                      recipe['strMealThumb'] ?? '',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      child: Text(
                                        recipe['strMeal'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 2),
                                    Text(
                                      recipe['strCategory'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).canvasColor,
                                        fontSize:14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                favoriteProvider.toggleFavoriteById(id);
                              },
                              child: Icon(
                                Icons.favorite,
                                color: Colors.amber.shade900,
                              ),
                            ),
                            SizedBox(width: 1,),
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox(); // Return empty container if snapshot has neither data nor error
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchRecipeById(String id) async {
    try {
      final apiUrl = 'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> meals = data['meals'];

        if (meals != null && meals.isNotEmpty) {
          return Map<String, dynamic>.from(meals.first);
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipe: $e');
      return null;
    }
  }
}
