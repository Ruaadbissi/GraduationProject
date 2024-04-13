import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/shoppingList/shoppingList.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'package:magic_cook1/screens/utils/helper/shoppingProvider.dart';
import 'package:magic_cook1/screens/utils/helper/shopping_list_manager.dart';

class detailsScreen extends StatefulWidget {
  final String recipeName;
  final String categoryName;

  const detailsScreen({Key? key, required this.recipeName, required this.categoryName}) : super(key: key);

  @override
  State<detailsScreen> createState() => _detailsScreenState();
}

class _detailsScreenState extends State<detailsScreen> {
  late ShoppingListManager _shoppingListManager;
  final PanelController _panelController = PanelController();
  late Map<String, dynamic> _details = {};
  late List<String> _tags = [];

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
            _fetchTags();
          });
        }
      } else {
        throw Exception('Failed to fetch details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching details: $e');
    }
  }

  Future<void> _fetchTags() async {
    try {
      final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?i=list'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tags = data['meals'];
        if (tags != null && tags.isNotEmpty) {
          setState(() {
            _tags = List<String>.from(tags.map((tag) => tag['strIngredient'] as String));
          });
        }
      } else {
        throw Exception('Failed to fetch tags. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tags: $e');
    }
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
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
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
              left: 0,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.amber.shade900,
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
                    children: [
                      Icon(Icons.link,color:  Colors.amber.shade900,),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          String videoLink = _details['strYoutube'] ?? '';
                          if (videoLink.isNotEmpty) {
                            //not yet
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
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          width: 190,
                          height: 45,
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade900,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ),
                        ),
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
                                    child: IngredientItem(name: '${_details['strMeasure$i']} ${_details['strIngredient$i']} ', recipeName: '',),
                                  ),
                                ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
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
              '______',
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

  const IngredientItem({Key? key, required this.name, required this.recipeName}) : super(key: key);

  @override
  _IngredientItemState createState() => _IngredientItemState();
}

class _IngredientItemState extends State<IngredientItem> {
  bool _isCartClicked = false;

  @override
  void initState() {
    super.initState();
    _checkItemStatus();
  }

  void _checkItemStatus() {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
    if (shoppingListProvider.shoppingList.contains(widget.name)) {
      setState(() {
        _isCartClicked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context);
    final isItemAdded = shoppingListProvider.shoppingList.contains(widget.name);
    final isClearing = shoppingListProvider.isClearing; // Get isClearing from the provider

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: isClearing // Check if the list is being cleared
                ? null // Disable onTap when the list is being cleared
                : () {
              setState(() {
                _isCartClicked = !_isCartClicked;
                if (!isClearing) { // Only perform action if not clearing the list
                  if (_isCartClicked) {
                    shoppingListProvider.addItem(widget.name, widget.recipeName);
                  } else {
                    shoppingListProvider.removeItem(widget.name);
                  }
                }
              });
            },
            child: _isCartClicked
                ? Icon(
              isClearing ? Icons.shopping_cart_outlined : Icons.shopping_cart,
              color: Colors.amber.shade900,
              size: 24,
            )
                : Icon(
              Icons.shopping_cart_outlined,
              color: Colors.amber.shade900,
              size: 24,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${widget.name} ',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
