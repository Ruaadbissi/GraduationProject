import 'dart:math'; // Importing math package for random number generation
import 'package:flutter/cupertino.dart'; // Importing Cupertino package for iOS-specific widgets
import 'package:flutter/material.dart'; // Importing Material package for Material Design widgets
import 'package:magic_cook1/screens/categoriesScreen/categoriesScreen.dart'; // Importing categories screen
import 'package:magic_cook1/screens/detailsScreen/detailsScreen.dart'; // Importing details screen
import 'package:magic_cook1/screens/recipesList/recipesList.dart';
import 'package:magic_cook1/screens/search_screen/search_screen.dart'; // Importing search screen
import 'package:magic_cook1/screens/utils/helper/favorite/favProvider.dart'; // Importing favorite provider
import 'package:magic_cook1/screens/utils/helper/favorite/favoriteWidget.dart'; // Importing favorite widget
import 'package:magic_cook1/screens/utils/helper/model.dart'; // Importing model
import 'package:magic_cook1/screens/utils/ui/drawer.dart'; // Importing custom drawer
import 'package:magic_cook1/screens/utils/ui/magazine.dart'; // Importing magazine widget
import 'package:magic_cook1/screens/utils/ui/progress_hud.dart'; // Importing progress HUD
import 'dart:convert'; // Importing JSON package for decoding
import 'package:http/http.dart' as http; // Importing http package for API requests
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart'; // Importing persistent bottom navigation bar
import 'package:provider/provider.dart'; // Importing provider for state management
import 'package:sizer/sizer.dart'; // Importing sizer for responsive design

class homeScreen extends StatefulWidget {
  final Function(List<placeModel>) updateFavorites; // Callback function to update favorites

  const homeScreen({Key? key, required this.updateFavorites}) : super(key: key);

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  late Future<void> _localizationFuture; // Future for localization initialization
  List<dynamic> categories = []; // List to hold categories
  List<dynamic> _randomRecipes = []; // List to hold random recipes
  Set<String> fetchedRecipeIds = {}; // Set to keep track of fetched recipe IDs

  @override
  void initState() {
    super.initState();
    _localizationFuture = initializeLocalization(); // Initialize localization
    fetchCategories(); // Fetch categories
    fetchRandomRecipes().then((recipes) {
      setState(() {
        _randomRecipes = recipes; // Set random recipes
      });
    }).catchError((error) {
      print('Error fetching random recipes: $error'); // Handle error
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      ProgressHud.shared.stopLoading(); // Stop loading indicator
    });
  }

  Future<void> initializeLocalization() async {
    await Future.delayed(Duration.zero); // Initialize localization (if needed)
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php')); // Fetch categories from API
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['categories']; // Parse and set categories
      });
    } else {
      throw Exception('Failed to load categories'); // Handle error
    }
  }

  Future<List<dynamic>> fetchRandomRecipes() async {
    List<dynamic> recipes = [];
    while (recipes.length < 10) { // Fetch 10 random recipes
      final response = await http.get(
          Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php')); // Fetch random recipe from API
      if (response.statusCode == 200) {
        List<dynamic> newRecipes = json.decode(response.body)['meals']; // Parse recipe data
        newRecipes = newRecipes.where((recipe) => !fetchedRecipeIds.contains(
            recipe['idMeal'])).toList(); // Filter out already fetched recipes
        recipes.addAll(newRecipes); // Add new recipes to the list
        fetchedRecipeIds.addAll(newRecipes.map((recipe) => recipe['idMeal'])); // Track fetched recipe IDs
      } else {
        throw Exception('Failed to load random recipes'); // Handle error
      }
    }
    recipes = recipes.sublist(0, min(10, recipes.length)); // Ensure only 10 recipes are returned

    return recipes;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FavoritePlacesProvider favoritePlacesProvider = Provider.of<FavoritePlacesProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0,
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // App bar width
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor, // Search bar background color
              borderRadius: BorderRadius.circular(9.h),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Stack(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for recipe', // Search bar hint text
                      hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 15.sp),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor, size: 4.h),
                      border: InputBorder.none,
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchScreen()), // Navigate to search screen
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor, size: 5.h),
      ),
      drawer: CustomDrawer(), // Custom drawer
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 2.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FoodMagazines(), // Food magazines widget
                    SizedBox(height: 1.h),
                    Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What would you like to cook today ? ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Theme.of(context).backgroundColor,
                            ),
                          ),
                          Text(
                            "Today’s recommendations",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Meal Categories",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: CategoriesScreen(), // Navigate to categories screen
                                    withNavBar: true,
                                  );
                                },
                                child: Text(
                                  "See all",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          tab(categories), // Display categories in a tab
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns in grid
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      shrinkWrap: true,
                      itemCount: _randomRecipes.length, // Number of random recipes
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final recipe = _randomRecipes[index];
                        return View(recipe); // Display recipe in grid
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 3.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Enjoy our Randoms!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tab(List<dynamic> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Horizontal scroll for categories
      child: Row(
        children: categories.map<Widget>((category) {
          return Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: Container(
              height: 10.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecipeListScreen(category: category['strCategory'])), // Navigate to recipe list screen
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.w)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category['strCategory'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Image.network(
                        category['strCategoryThumb'], height: 18.h, width: 18.w), // Category thumbnail image
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget View(dynamic recipe) {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailsPage(recipeName: recipe['strMeal'], categoryName: recipe['strCategory']), // Navigate to recipe details page
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.w),
                  color: Theme.of(context).cardColor,
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(3.w)),
                      child: Image.network(
                        recipe['strMealThumb'],
                        fit: BoxFit.cover,
                        height: 10.h,
                        width: double.infinity, // Recipe thumbnail image
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: Text(
                        recipe['strMeal'],
                        style: TextStyle(
                          color: Theme.of(context).backgroundColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          child: Text(
                            '${recipe['strCategory']} ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        FavoriteWidget(recipeId: recipe['idMeal'], recipeName: recipe['strMeal']) // Favorite widget
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
