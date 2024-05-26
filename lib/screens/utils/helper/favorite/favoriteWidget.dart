import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication library
import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/utils/helper/favorite/favProvider.dart'; // Provider for managing favorites
import 'package:magic_cook1/screens/utils/helper/userProvider.dart'; // Provider for managing user data
import 'package:provider/provider.dart'; // Provider package for state management
import 'package:sizer/sizer.dart'; // For responsive sizing

// Define a StatefulWidget for the FavoriteWidget
class FavoriteWidget extends StatefulWidget {
  final String recipeId;
  final String recipeName;

  const FavoriteWidget({Key? key, required this.recipeId, required this.recipeName}) : super(key: key);

  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState();
}

// Define the state for the FavoriteWidget
class _FavoriteWidgetState extends State<FavoriteWidget> {
  late FavoritePlacesProvider favoriteProvider; // Provider for managing favorites
  late UserProvider userProvider; // Provider for managing user data

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtain instances of the providers
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
            _showLoginRequiredDialog(context); // Show login required dialog if user is a guest
          } else {
            setState(() {
              favoriteProvider.toggleFavoriteById(widget.recipeId,widget.recipeName); // Toggle favorite status
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
              favoriteProvider.isFavoriteById(widget.recipeId) ? Icons.favorite : Icons.favorite_border, // Show filled or empty heart icon based on favorite status
              color: favoriteProvider.isFavoriteById(widget.recipeId) ? Colors.amber.shade900 : Colors.amber.shade900, // Heart icon color
              size: 7.w, // Icon size
            );
          },
        ),
      ),
    );
  }

  // Function to show login required dialog
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.w),
          ),
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'You must be logged in to add recipes to your favorites.', // Dialog message
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text(
                'OK', // OK button text
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10.sp), // Text style
              ),
            ),
          ],
        );
      },
    );
  }
}
