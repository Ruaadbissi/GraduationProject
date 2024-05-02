
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:magic_cook1/screens/categoriesScreen/categoriesScreen.dart';
import 'package:magic_cook1/screens/detailsScreen/detailsScreen.dart';
import 'package:magic_cook1/screens/recipesList/recipesList.dart';

import 'package:magic_cook1/screens/utils/helper/favProvider.dart';
import 'package:magic_cook1/screens/utils/helper/model.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:magic_cook1/screens/utils/ui/drawer.dart';
import 'package:magic_cook1/screens/utils/ui/progress_hud.dart';
import 'package:magic_cook1/screens/utils/ui/search/search.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


class homeScreen extends StatefulWidget {
  final Function(List<placeModel>) updateFavorites;

  const homeScreen({Key? key, required this.updateFavorites}) : super(key: key);

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {

  late Future<void> _localizationFuture;
  List<dynamic> categories = [];
  List<dynamic> _randomRecipes = [];
  Set<String> fetchedRecipeIds = {};

  @override
  void initState() {
    super.initState();
    _localizationFuture = initializeLocalization();
    fetchCategories();
    fetchRandomRecipes().then((recipes) {
      setState(() {
        _randomRecipes = recipes;
      });
    }).catchError((error) {
      print('Error fetching random recipes: $error');
      // Handle error as needed
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      ProgressHud.shared.stopLoading();
    });
  }

  Future<void> initializeLocalization() async {
    await Future.delayed(Duration.zero);
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['categories'];
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<dynamic>> fetchRandomRecipes() async {
    List<dynamic> recipes = [];
    while (recipes.length < 10) {
      final response = await http.get(
          Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'));
      if (response.statusCode == 200) {
        List<dynamic> newRecipes = json.decode(response.body)['meals'];
        newRecipes = newRecipes.where((recipe) => !fetchedRecipeIds.contains(
            recipe['idMeal'])).toList();
        // Add new recipes to the list
        recipes.addAll(newRecipes);
        fetchedRecipeIds.addAll(newRecipes.map((recipe) => recipe['idMeal']));
      } else {
        throw Exception('Failed to load random recipes');
      }
    }
    recipes = recipes.sublist(0, min(10, recipes.length));

    return recipes;
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> kitchenTools = [
      {'name': 'Chef\'s knife', 'icon': Icons.outdoor_grill},
      {'name': 'Cutting board', 'icon': Icons.content_cut},
      {'name': 'Mixing bowls', 'icon': Icons.kitchen},

      {'name': 'Saucepan', 'icon': Icons.kitchen},
      {'name': 'Skillet ', 'icon': Icons.local_dining},
      {'name': 'Wooden spoon', 'icon': Icons.local_pizza},
    ];

    FavoritePlacesProvider favoritePlacesProvider =
    Provider.of<FavoritePlacesProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: searchDark(),
          ),
        ),
        drawer: CustomDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //   Card(
                      //   margin: EdgeInsets.all(10),
                      //   elevation: 4,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(16),
                      //   ),
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(12),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           'Essential Kitchen Tools',
                      //           style: TextStyle(
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 16,
                      //             color: Colors.black87,
                      //           ),
                      //         ),
                      //         SizedBox(height: 12),
                      //         Wrap(
                      //           spacing: 16,
                      //           runSpacing: 12,
                      //           children: List.generate(
                      //             kitchenTools.length,
                      //                 (index) => ToolItem(tool: kitchenTools[index]),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      FoodMagazines(),
// Container(
                      //   margin: EdgeInsets.all(10),
                      //   height: 120,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(10),
                      //     color: Colors.grey.shade800, // Background color of the container
                      //   ),
                      // ),

                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What would you like to cook today ? ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.amber.shade900
                              ),
                            ),
                            Text(
                              "Today’s recommendations",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
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
                                    fontSize: 22,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: CategoriesScreen(),
                                      withNavBar: true,
                                    );
                                  },
                                  child: Text(
                                    "See all",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            tab(categories),
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                        ),
                        shrinkWrap: true,
                        itemCount: _randomRecipes.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final recipe = _randomRecipes[index];
                          return View(recipe);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Enjoy our Randoms!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget tab(List<dynamic> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map<Widget>((category) {
          return Padding(
            padding: EdgeInsets.only(right: 14.0),
            child: Container(
              height: 70,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        RecipeListScreen(category: category['strCategory'],)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme
                      .of(context)
                      .cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category['strCategory'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ),
                    ),
                    SizedBox(width: 15),
                    Image.network(
                        category['strCategoryThumb'], height: 50, width: 50),
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
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailsPage(recipeName: recipe['strMeal'], categoryName: recipe['strCategory'],),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        recipe['strMealThumb'],
                        fit: BoxFit.cover,
                        height: 100,
                        width: double.infinity,
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        recipe['strMeal'],
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '${recipe['strCategory']} ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        FavoriteWidget(recipeId: recipe['idMeal'])
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

class FavoriteWidget extends StatefulWidget {
  final String recipeId;

  const FavoriteWidget({Key? key, required this.recipeId}) : super(key: key);

  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  late FavoritePlacesProvider favoriteProvider;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    favoriteProvider = Provider.of<FavoritePlacesProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Check if the user is a guest user
          if (userProvider.userName == "Guest User") {
            _showLoginRequiredDialog(context);
          } else {
            setState(() {
              favoriteProvider.toggleFavoriteById(widget.recipeId);
            });
          }
        } else {
          // User is not authenticated, show login required dialog
          _showLoginRequiredDialog(context);
        }
      },
      child: Center(
        child: Consumer<FavoritePlacesProvider>(
          builder: (context, favoriteProvider, child) {
            return Icon(
              favoriteProvider.isFavoriteById(widget.recipeId) ? Icons.favorite : Icons.favorite_border,
              color: favoriteProvider.isFavoriteById(widget.recipeId) ? Colors.amber.shade900 : Colors.amber.shade900,
            );
          },
        ),
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'You must be logged in to add recipes to your favorites.',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ToolItem extends StatelessWidget {
  final Map<String, dynamic> tool;

  const ToolItem({Key? key, required this.tool}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            tool['icon'],
            color: Colors.amber.shade900,
            size: 24,
          ),
        ),
        SizedBox(width: 10),
        Text(
          tool['name'],
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
class FoodMagazines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Food Magazines',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.amber.shade900,
              ),
            ),
            SizedBox(height: 12),
            FoodMagazineItem(
              magazineName1: 'Food & Wine',
              imageUrl1: 'assets/food.png',
              magazineUrl1: 'https://en.wikipedia.org/wiki/Food_%26_Wine',
              magazineName2: 'Bon Appétit',
              imageUrl2: 'assets/bon.png',
              magazineUrl2: 'https://www.bonappetit.com/',
              magazineName3: 'Saveur',
              imageUrl3: 'assets/saveur.png',
              magazineUrl3: 'https://www.saveur.com/',
            ),
          ],
        ),
      ),
    );
  }
}
class FoodMagazineItem extends StatelessWidget {
  final String magazineName1;
  final String imageUrl1;
  final String magazineUrl1;
  final String magazineName2;
  final String imageUrl2;
  final String magazineUrl2;
  final String magazineName3;
  final String imageUrl3;
  final String magazineUrl3;

  const FoodMagazineItem({
    required this.magazineName1,
    required this.imageUrl1,
    required this.magazineUrl1,
    required this.magazineName2,
    required this.imageUrl2,
    required this.magazineUrl2,
    required this.magazineName3,
    required this.imageUrl3,
    required this.magazineUrl3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMagazineItem(
          magazineName1,
          imageUrl1,
          magazineUrl1,
        ),
        SizedBox(width: 8),
        _buildMagazineItem(
          magazineName2,
          imageUrl2,
          magazineUrl2,
        ),
        SizedBox(width: 8),
        _buildMagazineItem(
          magazineName3,
          imageUrl3,
          magazineUrl3,
        ),
      ],
    );
  }

  Widget _buildMagazineItem(
      String magazineName,
      String imageUrl,
      String magazineUrl,
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _launchURL(magazineUrl);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Image.asset(
                  imageUrl,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: 120, // Adjust the height as needed
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    magazineName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14, // Adjust the font size as needed
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (url.isNotEmpty) {
      try {
        await launch(url);
      } catch (e) {
        print('Error launching URL: $e');
      }
    } else {
      print('URL is null or empty');
    }
  }


}
