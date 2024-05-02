import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
import 'package:magic_cook1/screens/utils/helper/customReadMore.dart';
import 'package:magic_cook1/screens/utils/helper/shoppingList/shoppingProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../utils/helper/shoppingList/shopping_list_manager.dart';


class shoppingList extends StatefulWidget {
  final String recipeName;
  final Function(String) onItemRemoved;


  const shoppingList({Key? key, required this.recipeName, required this.onItemRemoved}) : super(key: key);

  @override
  State<shoppingList> createState() => _shoppingListState();
}
class _shoppingListState extends State<shoppingList> {
  List<Map<String, dynamic>> _shoppingList = [];

  @override
  void initState() {
    super.initState();
    _initShoppingList();
  }

  Future<void> _initShoppingList() async {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
    setState(() {
      _shoppingList = shoppingListProvider.shoppingList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.shopping_list,
          style: TextStyle(
            fontSize: 35,
            color: Theme.of(context).primaryColor,
            fontFamily: "fonts/Raleway-Bold",
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/list.jpg"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Positioned.fill(
                child: Container(
                  color: Theme.of(context).shadowColor,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: 25),
                Expanded(
                  child: Consumer<ShoppingListProvider>(
                    builder: (context, shoppingListProvider, child) {
                      _shoppingList = shoppingListProvider.shoppingList;
                      return ListView.builder(
                        itemCount: _shoppingList.length,
                        itemBuilder: (context, index) {
                          final item = _shoppingList[index];
                          final ingredient = item['name'];
                          final imageUrl = item['imageUrl'];

                          return Dismissible(
                            key: Key(ingredient),
                            onDismissed: (direction) {
                              _removeItem(ingredient);
                            },
                            background: Container(
                              color: Colors.amber.shade900,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                            ),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).shadowColor,
                                borderRadius: BorderRadius.circular(20), // Rounded borders
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Ingredient image
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // Ingredient name
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomReadMoreText(
                                            '${index + 1})  $ingredient ',
                                            trimLines: 1,
                                            style: TextStyle(
                                              fontSize: 21,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            lessStyle: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade900,
                                            ),
                                            moreStyle: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );

                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearShoppingList,
        backgroundColor: Colors.amber.shade900,
        child: Icon(Icons.delete, color: Colors.white),
      ),
    );
  }

  void _removeItem(String item) {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
    shoppingListProvider.removeItem(item);
    widget.onItemRemoved(item); // Call the callback function
  }

  void _clearShoppingList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Are you sure you want to clear the shopping list?',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
                _clearList(); // Clear the shopping list
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearList() {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
    shoppingListProvider.clearList();
  }
}

