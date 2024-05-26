import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:magic_cook1/screens/detailsScreen/detailsScreen.dart';
import 'package:magic_cook1/screens/utils/helper/favorite/favoriteWidget.dart';
import 'dart:convert';

import 'package:sizer/sizer.dart';


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

  Future<void> _searchRecipes(String query) async{
    setState(() {
      _recipeListFuture = fetchRecipesByCategory(widget.category)
          .then((recipes) => _filterRecipes(recipes, query));
    });
  }

  List<dynamic> _filterRecipes(List<dynamic> recipes, String query) {
    if (query.isEmpty) {
      return recipes; // Return all recipes if the query is empty
    } else {
      // Filter recipes based on search query
      return recipes.where((recipe) =>
          recipe['strMeal'].toLowerCase().contains(query.toLowerCase())).toList();
    }
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
            color: Theme.of(context).primaryColor,
            size: 5.h,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child:  Container(
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(9.h),
              border: Border.all(color: Theme.of(context).primaryColor,),
            ),
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 1.w),
              child: TextField(
                onChanged: _searchRecipes,
                decoration: InputDecoration(
                  hintText: 'Search for recipe',
                  hintStyle: TextStyle(color: Theme.of(context).hintColor,fontSize: 15.sp),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor,size: 4.h),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 2.h),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _recipeListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).backgroundColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Theme.of(context).backgroundColor,),
                      ),
                    );
                  } else {
                    final List<dynamic> recipes = snapshot.data ?? [];
                    if (recipes.isEmpty) {
                      return Center(
                        child: Text(
                          'No recipes found.',
                          style: TextStyle(color: Theme.of(context).backgroundColor,),
                        ),
                      );
                    } else {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return buildRecipeCard(context, recipe);
                        },
                      );
                    }
                  }
                },
              ),
            ),
            SizedBox(height: 4.h),

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
        margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3.w),
                  topRight: Radius.circular(3.w),
                ),
                child: recipe['strMealThumb'] != null
                    ? Image.network(
                  recipe['strMealThumb'],
                  fit: BoxFit.cover,
                  height: 14.h,
                )
                    : Placeholder(),
              ),
            ),
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Text(
                recipe['strMeal'],
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).backgroundColor,
                ),
                maxLines:1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${recipe['strArea']} food',
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  FavoriteWidget(recipeId: recipe['idMeal'],recipeName: recipe['strMeal'],)
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
