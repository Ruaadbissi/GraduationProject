import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/detailsScreen/detailsScreen.dart'; // Importing details screen
import 'package:provider/provider.dart'; // Importing provider for state management
import 'package:http/http.dart' as http; // Importing http package for API requests
import 'dart:convert'; // Importing json package for JSON decoding

import 'package:magic_cook1/screens/utils/helper/favorite/favProvider.dart'; // Importing favorite provider
import 'package:sizer/sizer.dart'; // Importing sizer for responsive design

class FavoritesPage extends StatelessWidget { // Stateless widget for favorite recipes page
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Set background color
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No elevation
        title: Text(
          "Favourite List",
          style: TextStyle(
            fontSize: 25.sp,
            color: Theme.of(context).primaryColor,
            fontFamily: "fonts/Raleway-Bold",
          ),
        ),
      ),
      body: Consumer<FavoritePlacesProvider>( // Using provider to get favorite places
        builder: (context, favoriteProvider, child) {
          final List favoriteIds = favoriteProvider.favoriteList.map((item) => item['id']).toList(); // Get favorite IDs
          return ListView.builder(
            itemCount: favoriteProvider.favoriteList.length, // Number of favorite items
            itemBuilder: (context, index) {
              final Map<String, dynamic> recipe = favoriteProvider.favoriteList[index]; // Get recipe data
              final String id = recipe['id']; // Get recipe ID
              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchRecipeById(id), // Fetch recipe data by ID
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).backgroundColor,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Show error message
                  }
                  if (snapshot.hasData) {
                    final recipe = snapshot.data!; // Get recipe data
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailsPage(
                              recipeName: recipe['strMeal'], // Pass recipe name to details page
                              categoryName: recipe['strCategory'], // Pass category name to details page
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(2.w),
                        width: 90.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.w),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 2.w,
                                  height: 2.h,
                                ),
                                Container(
                                  width: 15.w,
                                  height: 8.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.h),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.h),
                                    child: Image.network(
                                      recipe['strMealThumb'] ?? '', // Display recipe image
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 60.w,
                                      child: Text(
                                        recipe['strMeal'] ?? '', // Display recipe name
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      recipe['strCategory'] ?? '', // Display recipe category
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:Theme.of(context).hintColor,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                favoriteProvider.toggleFavoriteById(id, recipe['strMeal']); // Toggle favorite status
                              },
                              child: Icon(
                                favoriteProvider.isFavoriteById(id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Theme.of(context).backgroundColor,
                              ),
                            ),
                            SizedBox(width: 1.w,),
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox(); // Return empty if no data
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchRecipeById(String id) async {
    // Function to fetch recipe data by ID
    try {
      final apiUrl = 'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id'; // API URL
      final response = await http.get(Uri.parse(apiUrl)); // Make HTTP request

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // Decode JSON response
        final List<dynamic> meals = data['meals']; // Get meals data

        if (meals != null && meals.isNotEmpty) {
          return Map<String, dynamic>.from(meals.first); // Return first meal data
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}'); // Handle HTTP error
      }
    } catch (e) {
      print('Error fetching recipe: $e'); // Print error to console
      throw e; // Throw error
    }
  }
}
