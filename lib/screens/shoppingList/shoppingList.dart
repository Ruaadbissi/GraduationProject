import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
import 'package:magic_cook1/screens/utils/helper/customReadMore.dart';
import 'package:magic_cook1/screens/utils/helper/shoppingProvider.dart';
import 'package:provider/provider.dart';

class shoppingList extends StatefulWidget {
  final String recipeName;

  const shoppingList({Key? key, required this.recipeName}) : super(key: key);

  @override
  State<shoppingList> createState() => _shoppingListState();
}

class _shoppingListState extends State<shoppingList> {
  late List<String> _shoppingList;

  @override
  void initState() {
    super.initState();
    _initShoppingList();
  }

  Future<void> _initShoppingList() async {
    final shoppingListProvider =
    Provider.of<ShoppingListProvider>(context, listen: false);
    setState(() {
      _shoppingList = shoppingListProvider.shoppingList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.shopping_list,
                      style: TextStyle(
                        fontSize: 35,
                        color: Theme.of(context).primaryColor,
                        fontFamily: "fonts/Raleway-Bold",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Expanded(
                  child: Consumer<ShoppingListProvider>(
                    builder: (context, shoppingListProvider, child) {
                      List<String> _shoppingList =
                          shoppingListProvider.shoppingList;
                      return ListView.builder(
                        itemCount: _shoppingList.length,
                        itemBuilder: (context, index) {
                          final ingredient = _shoppingList[index];
                          return Dismissible(
                            key: Key(ingredient),
                            onDismissed: (direction) {
                              _removeItem(ingredient);
                            },
                            background: Container(
                              color: Colors.amber.shade900,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete,
                                  color: Theme.of(context).primaryColor),
                            ),
                            child: ListTile(
                              title: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey.withOpacity(0.3),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x3f000000),
                                      offset: Offset(0, 4),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: CustomReadMoreText(
                                        '${index + 1}\)  $ingredient (${widget.recipeName})',
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
        child: Icon(Icons.delete,
        color: Colors.white,),
      ),
    );
  }

  void _removeItem(String item) {
    final shoppingListProvider =
    Provider.of<ShoppingListProvider>(context, listen: false);
    setState(() {
      shoppingListProvider.removeItem(item);
    });
  }
  void _clearShoppingList() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title:  Text('Are you sure you want to clear the shopping list?',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: Text('No',
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
              child: Text('Yes',
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


