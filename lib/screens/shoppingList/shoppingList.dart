import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart'; // Localization support
import 'package:magic_cook1/screens/utils/helper/customReadMore.dart'; // Custom widget for reading more text
import 'package:magic_cook1/screens/utils/helper/shoppingList/shoppingProvider.dart'; // Provider for managing shopping list data
import 'package:provider/provider.dart'; // Provider package for state management
import 'package:sizer/sizer.dart'; // For responsive sizing
import 'package:oktoast/oktoast.dart'; // Package for displaying toast notifications

// Define a StatefulWidget for the shopping list screen
class shoppingList extends StatefulWidget {
  final String recipeName;
  final Function(String) onItemRemoved;

  const shoppingList({Key? key, required this.recipeName, required this.onItemRemoved}) : super(key: key);

  @override
  State<shoppingList> createState() => _ShoppingListState();
}

// Define the state for the shopping list screen
class _ShoppingListState extends State<shoppingList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Shopping List",
          style: TextStyle(
            fontSize: 25.sp,
            color: Theme.of(context).primaryColor,
            fontFamily: "fonts/Raleway-Bold",
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
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
                SizedBox(height: 2.h),
                Expanded(
                  child: Consumer<ShoppingListProvider>(
                    builder: (context, shoppingListProvider, child) {
                      return Builder(
                        builder: (context) {
                          return ListView.builder(
                            itemCount: shoppingListProvider.shoppingList.length,
                            itemBuilder: (context, index) {
                              final item = shoppingListProvider.shoppingList[index];
                              final ingredient = item['name'] ?? '';
                              final imageUrl = item['imageUrl'] ?? '';

                              return Dismissible(
                                key: Key(ingredient),
                                onDismissed: (direction) {
                                  _removeItem(ingredient, shoppingListProvider);
                                },
                                background: Container(
                                  color: Theme.of(context).backgroundColor,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 4.w),
                                  child: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                                ),
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 2.w, horizontal: 5.w),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(7.w), // Rounded borders
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: Offset(0, 2), // Shadow offset
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 2.w),
                                    title: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Ingredient image
                                        Container(
                                          width: 12.w,
                                          height: 7.h,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(2.w),
                                            image: DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        // Ingredient name
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Custom read-more text widget
                                              CustomReadMoreText(
                                                '${index + 1})  $ingredient ',
                                                trimLines: 1,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                                lessStyle: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).backgroundColor,
                                                ),
                                                moreStyle: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).backgroundColor,
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
        onPressed: _clearShoppingList, // Call _clearShoppingList function on button press
        backgroundColor: Theme.of(context).backgroundColor,
        child: Icon(Icons.delete, color: Theme.of(context).primaryColor),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Function to remove an item from the shopping list
  void _removeItem(String item, ShoppingListProvider shoppingListProvider) {
    // Call the callback function to remove the item from the parent widget
    widget.onItemRemoved(item);

    // Remove the item synchronously from the provider
    shoppingListProvider.removeItem(item);
  }

  // Function to clear the entire shopping list
  void _clearShoppingList() {
    // Show confirmation dialog before clearing the list
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.w),
          ),
          title: Text(
            'Are you sure you want to clear the shopping list?',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          actions: <Widget>[
            // "No" button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 10.sp,
                ),
              ),
            ),
            // "Yes" button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _clearList(); // Call _clearList function to clear the list
              },
              child: Text(
                'Yes',
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

  // Function to clear the shopping list
  void _clearList() {
    final shoppingListProvider = Provider.of<ShoppingListProvider>(context, listen: false);
    shoppingListProvider.clearList(); // Call the clearList function from the provider
  }
}
