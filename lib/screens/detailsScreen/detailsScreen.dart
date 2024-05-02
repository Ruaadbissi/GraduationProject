import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/mealPlanning/mealPlanning.dart';
import 'package:magic_cook1/screens/utils/helper/planning/mealPlanningPref.dart';
import 'package:magic_cook1/screens/utils/helper/shoppingList/shoppingProvider.dart';
import 'package:magic_cook1/screens/utils/helper/shoppingList/shopping_list_manager.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class RecipeDetailsPage extends StatefulWidget {
  final String recipeName;
  final String categoryName;

  const RecipeDetailsPage({Key? key, required this.recipeName, required this.categoryName}) : super(key: key);

  @override
  State<RecipeDetailsPage> createState() => _detailsScreenState();
}

class _detailsScreenState extends State<RecipeDetailsPage> {
  late ShoppingListManager _shoppingListManager;
  final PanelController _panelController = PanelController();
  late Map<String, dynamic> _details = {};

  @override
  void initState() {
    super.initState();
    _initShoppingListManager();
    _fetchDetails();
  }

  Future<void> _initShoppingListManager() async {
    _shoppingListManager = ShoppingListManager();
    await _shoppingListManager.init();
  }

  Future<void> _fetchDetails() async {
    try {
      final encodedRecipeName = Uri.encodeComponent(widget.recipeName);
      final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$encodedRecipeName'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'];
        if (meals != null && meals.isNotEmpty) {
          setState(() {
            _details = meals[0];
          });
        }
      } else {
        throw Exception('Failed to fetch details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching details: $e');
    }
  }

  void updateCartState() {
    // Update the state of the cart icon
    setState(() {
      // Update the state based on whether the ingredient is in the shopping list
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _buildContent(),
            SlidingUpPanel(
              controller: _panelController,
              minHeight: 0,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              panel: _buildInstructionsPanel(),
              borderRadius:const BorderRadius.only(
                topLeft: Radius.circular(33),
                topRight: Radius.circular(33),
              ),
              color: Color(0xFF1C1818),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.30,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: Image.network(
                  _details['strMealThumb'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.30,
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.2, 1.0],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.18,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _details['strMeal'] ?? '',
                    style: TextStyle(
                      fontSize: 26,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '${_details['strArea']} food',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 12,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items at the ends
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('details').doc(widget.recipeName).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            if (snapshot.data!.exists) {
                              String timer = snapshot.data!['timer'] ?? 0;
                              return
                                Text(
                                  'Timer: ${timer.toString()} ',
                                  style: TextStyle(

                                    fontSize: 16,

                                    color: Colors.amber.shade900,
                                  ),
                                );


                            } else {
                              return Text('Timer information not available');
                            }
                          }
                          return Text('No data available');
                        },
                      ),
                      // Add Recipe to Calendar button
                      IconButton(
                        icon: Icon(
                          Icons.calendar_month,
                          color: Colors.amber.shade900,
                          size: 32,
                        ),
                        onPressed: () async {
                          String recipeName = widget.recipeName; // Get the recipe name
                          await MealPlanningRecipePreferences.saveRecipeName(recipeName); // Save the recipe name
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: Theme.of(context).cardColor,
                                title: Text('Do you want to add this recipe to your meal planning?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                    },
                                    child: Text(
                                      'No',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      String recipeName = widget.recipeName; // Get the recipe name
                                      await MealPlanningRecipePreferences.saveRecipeName(recipeName); // Save the recipe name
                                      Navigator.pop(context); // Close dialog
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MealPlanningScreen(recipeName: widget.recipeName),
                                        ),
                                      );

                                    },

                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),

                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      String videoLink = _details['strYoutube'] ?? '';
                      if (videoLink.isNotEmpty) {
                        launch(videoLink); // Assuming you're using the url_launcher package
                      } else {
                        // Handle case where video link is not available
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Video Not Available'),
                            content: Text('Sorry, no video instructions are available for this recipe.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Watch the Instructions Video',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.amber.shade900,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items at the ends
                        children: [
                          Container(
                            width: 150,
                            height: 45,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade900,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child:
                            Center(
                              child: Row(
                                children: [
                                  Text(
                                    'Ingredients',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 110,
                            height: 45,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade900,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child:
                            Center(
                              child: Row(
                                children: [
                                  Text(
                                    'Add ingredient\nto cart',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      if (_details['strIngredient1'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 1; i <= 30; i++)
                              if (_details['strIngredient$i'] != null && _details['strIngredient$i'] != '')
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Container(
                                      child: IngredientItem(
                                        name: '${_details['strMeasure$i']} ${_details['strIngredient$i']}',
                                        recipeName: '',
                                        ingredient: _details['strIngredient$i'],
                                        imageUrl: 'https://www.themealdb.com/images/ingredients/${_details['strIngredient$i'].toLowerCase()}.png',
                                        updateCartState: updateCartState,
                                      )
                                  ),
                                ),
                          ],
                        ),

                    ],
                  ),
                  SizedBox(height: 16),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('details').doc(widget.recipeName).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        if (snapshot.data!.exists) {
                          Map<String, dynamic> nutritionInfo = snapshot.data!['utrition_info'] ?? {};
                          return Card(
                            elevation: 4, // Add elevation for a shadow effect
                            margin: EdgeInsets.all(10), // Add margin around the card
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Nutrition Information',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade900, // Adjust text color as needed
                                    ),
                                  ),
                                ),
                                Divider(), // Add a divider for separation
                                // Use ListView to display nutrition details
                                ListView(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: nutritionInfo.entries.map((entry) {
                                    return ListTile(
                                      title: Text(
                                        '${entry.key}: ${entry.value}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white, // Adjust text color as needed
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text('Nutrition information not available');
                        }
                      }
                      return Text('No data available');
                    },
                  ),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _panelController.open();
                      },
                      child: Text(
                        'View Instructions',
                        style: TextStyle(
                          color:Theme.of(context).scaffoldBackgroundColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.amber.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '__',
              style: TextStyle(
                fontSize: 24,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 13),
          Text(
            'Instructions',
            style: TextStyle(
              fontSize: 24,
              color: Colors.amber.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _details['strInstructions'] != null
                  ? _details['strInstructions'].split(' \n\n').length
                  : 0,
              itemBuilder: (context, index) {
                String step =
                    _details['strInstructions']?.split(' \n\n')[index] ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    step,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class IngredientItem extends StatefulWidget {
  final String name;
  final String recipeName;
  final String ingredient;
  final String imageUrl;
  final Function updateCartState; // Callback function

  const IngredientItem({
    Key? key,
    required this.name,
    required this.recipeName,
    required this.ingredient,
    required this.imageUrl,
    required this.updateCartState,
  }) : super(key: key);

  @override
  _IngredientItemState createState() => _IngredientItemState();
}

class _IngredientItemState extends State<IngredientItem> {
  late UserProvider _userProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context); // Get the UserProvider from the context
  }

  void _addToShoppingList(String ingredient) {
    final shoppingListProvider =
    Provider.of<ShoppingListProvider>(context, listen: false);
    shoppingListProvider.addItem(
      widget.name,
      'https://www.themealdb.com/images/ingredients/${widget.ingredient.toLowerCase()}.png',
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
            'You need to be logged in to add ingredients to shopping list.',
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
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context);
    final isClearing = shoppingListProvider.isClearing;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
      child: Row(
        children: [
          // Ingredient image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 8),
          // Ingredient name
          Expanded(
            child: Text(
              '${widget.name} ',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          // Cart icon
          GestureDetector(
            onTap: isClearing
                ? null
                : () {
              final User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (_userProvider.userName == "Guest User") {
                  _showLoginRequiredDialog(context);
                } else {
                  _addToShoppingList(widget.ingredient);
                }
              } else {
                _showLoginRequiredDialog(context);
              }
            },
            child: Icon(
              Icons.add,
              color: Colors.amber.shade900,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

