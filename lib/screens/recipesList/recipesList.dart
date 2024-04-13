import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:magic_cook1/screens/detailsScreen/detailsScreen.dart';
import 'dart:convert';

import 'package:magic_cook1/screens/utils/ui/search/search.dart';

class recipesList extends StatefulWidget {
  final String categoryName;

  const recipesList({Key? key, required this.categoryName}) : super(key: key);

  @override
  _recipesListState createState() => _recipesListState();
}

class _recipesListState extends State<recipesList> {
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.categoryName}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'];
        if (meals != null) {
          // Fetch detailed information for each recipe
          final List<Map<String, dynamic>> detailedRecipes = [];
          for (final meal in meals) {
            final idMeal = meal['idMeal'];
            final detailResponse = await http.get(Uri.parse(
                'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$idMeal'));
            if (detailResponse.statusCode == 200) {
              final detailData = json.decode(detailResponse.body);
              final detailMeal = detailData['meals'][0];
              detailedRecipes.add(detailMeal);
            }
          }
          setState(() {
            recipes = detailedRecipes;
          });
        }
      } else {
        throw Exception(
            'Failed to fetch recipes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.amber.shade900,
                    size: 40,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.72,
                  child: searchDark(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose your recipe',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      height: 1.2125,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.categoryName,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _buildRecipesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesList() {
    if (recipes.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => detailsScreen(
                      recipeName: recipe['strMeal'],
                      categoryName: widget.categoryName, // Assuming you have categoryName available here
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(recipe['strMealThumb']),
                  ),
                  title: Text(
                    recipe['strMeal'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color:  Theme.of(context).primaryColor,
                    ),
                  ),
                  subtitle: Text(
                    '${recipe['strArea']} food',
                    style: TextStyle(
                      fontSize: 14,
                      color:  Theme.of(context).canvasColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
