import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/mealPlanning/mealPlanning.dart';
import 'package:magic_cook1/screens/utils/helper/shoppingList/shoppingProvider.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
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
  late UserProvider _userProvider;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context);
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
    setState(() {
    });
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.w),
          ),
          backgroundColor: Theme.of(context).canvasColor,
          title: Text(
            'You need to be logged in to add recipe to your meal planning.',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp

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
                  fontSize: 10.sp,
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              _buildContent(),
              SlidingUpPanel(
                controller: _panelController,
                minHeight: 0,
                maxHeight: MediaQuery.of(context).size.height ,
                panel: _buildInstructionsPanel(),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.w),
                  topRight: Radius.circular(10.w),
                ),
                color: Theme.of(context).canvasColor,
              ),
            ],
          ),
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
                    color: Theme.of(context).shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.w),
                  bottomRight: Radius.circular(10.w),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.w),
                  bottomRight: Radius.circular(10.w),
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
              left: 4.w,
              right: 4.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _details['strMeal'] ?? '',
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${_details['strArea']} food',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 2.w,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).primaryColor,
                  size: 5.h,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        SizedBox(height:1.h),
        Padding(
          padding:  EdgeInsets.only(left: 4.w,right:4.w),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(
                    children:[
                      Container(
                        height: 5.h,
                        width: 10.w,
                        decoration: BoxDecoration(
                          color:Theme.of(context).backgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.link,
                          size: 6.w,
                          color:Theme.of(context).scaffoldBackgroundColor,

                        ),
                      ),
                      SizedBox(width:1.w),
                      GestureDetector(
                        onTap: () {
                          String videoLink = _details['strYoutube'] ?? '';
                          if (videoLink.isNotEmpty) {
                            launch(videoLink);
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
                            text: 'Watch Recipe Video',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:Theme.of(context).backgroundColor,

                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
                IconButton(
                  icon: Container(
                    height: 5.h,
                    width: 10.w,
                    decoration: BoxDecoration(
                      color:Theme.of(context).backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color:Theme.of(context).scaffoldBackgroundColor,
                      size: 6.w,
                    ),
                  ),
                  onPressed: () async {
                    final User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      if (_userProvider.userName == "Guest User") {
                        _showLoginRequiredDialog(context);
                      } else {
                        String recipeName = widget.recipeName ?? '';
                        if (recipeName.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.w),
                                ),
                                backgroundColor: Theme.of(context).canvasColor,
                                title: Text(
                                  'Do you want to add this recipe to your meal planning?',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp

                                  ),),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'No',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.sp
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context); // Close dialog
                                      // Navigate to the calendar screen to choose the date and save the recipe
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MealPlanningScreen(
                                            recipeName: recipeName,
                                            showLeadingArrow: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.sp
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    } else {
                      _showLoginRequiredDialog(context);
                    }
                  },
                )
              ]
          ),
        ),
        Padding(
          padding:  EdgeInsets.only(left: 4.w,right:4.w,top:3.w),
          child: Container(
            width: double.infinity,
            height: 6.h,
            decoration: BoxDecoration(
              color:Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:  EdgeInsets.only(left:6.w),
                  child: Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(right:4.w),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 4.h,
                    color:Theme.of(context).scaffoldBackgroundColor,

                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding:  EdgeInsets.only(left:4.w,right:4.w),
          child: Container(
            height:33.h,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5.w),
              border: Border.all(
                color: Theme.of(context).backgroundColor,
                width: 2,
              ),
            ),
            padding:  EdgeInsets.all(3.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 1.h),
                  for (int i = 1; i <= 30; i++)
                    if (_details['strIngredient$i'] != null && _details['strIngredient$i'] != '')
                      Padding(
                        padding:  EdgeInsets.symmetric(vertical: 2.w),
                        child: Container(
                          child: IngredientItem(
                            name: '${_details['strMeasure$i']} ${_details['strIngredient$i']}',
                            recipeName: '',
                            ingredient: _details['strIngredient$i'],
                            imageUrl: 'https://www.themealdb.com/images/ingredients/${_details['strIngredient$i'].toLowerCase()}.png',
                            updateCartState: updateCartState,
                          ),
                        ),
                      ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Center(
          child: ElevatedButton(
            onPressed: () {
              _panelController.open();
            },
            child: Text(
              'View Instructions',
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.w),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsPanel() {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 5.w, vertical:2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '-----',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.amber.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Instructions',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.amber.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: ListView.builder(
              itemCount: _details['strInstructions'] != null
                  ? _details['strInstructions'].split(' \n\n').length
                  : 0,
              itemBuilder: (context, index) {
                String step =
                    _details['strInstructions']?.split(' \n\n')[index] ?? '';
                return Padding(
                  padding:  EdgeInsets.only(bottom:15.h),
                  child: Text(
                    step,
                    style: TextStyle(
                      fontSize: 15.sp,
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
  final Function updateCartState;

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
    _userProvider = Provider.of<UserProvider>(context);
  }

  void _addToShoppingList(String ingredient) {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
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
          backgroundColor:  Theme.of(context).canvasColor,
          title: Text(
            'You need to be logged in to add ingredients to the shopping list.',
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
