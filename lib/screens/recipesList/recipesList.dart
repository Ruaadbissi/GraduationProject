import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../detailsScreen/detailsScreen.dart';
import '../homeScreen/homeScreen.dart';
import '../utils/helper/favProvider.dart';
import '../utils/ui/search/search-api.dart';

class RecipeListScreen extends StatefulWidget {
  final String category;

  const RecipeListScreen({required this.category});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late Future<List<dynamic>> _recipeListFuture;

  @override
  void initState() {
    super.initState();
    _recipeListFuture = fetchRecipesByCategory(widget.category);
  }

  Future<List<dynamic>> fetchRecipesByCategory(String category) async {
    final response = await http.get(
      Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'),
    );
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
        return detailedRecipes;
      }
    }
    // Return an empty list if there's any error or no data
    return [];
  }

  Future<void> _searchRecipes(String query) async {
    setState(() {
      _recipeListFuture = RecipeSearch.searchRecipes(query);
    });
  }

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
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child:  SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Theme.of(context).primaryColor,),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  onChanged: _searchRecipes, // Call _searchRecipes on change
                  decoration: InputDecoration(
                    hintText: 'Search for recipe',
                    hintStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _recipeListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final recipe = snapshot.data![index];
                        return buildRecipeCard(context, recipe);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRecipeCard(BuildContext context, recipe) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailsPage(
              recipeName: recipe['strMeal'],
              categoryName: widget.category,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: recipe['strMealThumb'] != null
                    ? Image.network(
                  recipe['strMealThumb'],
                  fit: BoxFit.cover,
                )
                    : Placeholder(),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                recipe['strMeal'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${recipe['strArea']} food',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  FavoriteWidget(recipeId: recipe['idMeal'])
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
