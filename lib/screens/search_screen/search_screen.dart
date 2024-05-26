import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:magic_cook1/screens/detailsScreen/detailsScreen.dart'; // For navigating to the details screen
import 'package:magic_cook1/screens/utils/helper/favorite/favoriteWidget.dart'; // For the favorite widget
import 'package:sizer/sizer.dart'; // For responsive sizing

// Define a stateful widget for the search screen
class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

// Define the state for the search screen
class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController; // Controller for the search input
  List<dynamic> _searchResults = []; // List to store search results
  bool _isLoading = false; // Boolean to show loading indicator

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(); // Initialize the search controller
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose of the controller when not needed
    super.dispose();
  }

  // Function to search for meals based on a query
  Future<void> _searchMeals(String query) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    // Make an HTTP GET request to fetch meal data
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$query'));

    if (response.statusCode == 200) {
      setState(() {
        _searchResults = json.decode(response.body)['meals']; // Decode JSON response and update search results
      });
    } else {
      // Handle error (e.g., show a message to the user)
    }

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).shadowColor,
              borderRadius: BorderRadius.circular(9.h),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _searchMeals(value); // Perform search if the input is not empty
                  } else {
                    setState(() {
                      _searchResults.clear(); // Clear search results if input is empty
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for recipe',
                  hintStyle: TextStyle(color: Theme.of(context).hintColor, fontSize: 15.sp),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor, size: 4.h),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).backgroundColor,
        ),
      )
          : _buildSearchResults(), // Show search results or loading indicator
    );
  }

  // Widget to build search results
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No Results',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 11.sp,
          ),
        ),
      ); // Show "No Results" if search results are empty
    }

    // Build a grid view for displaying search results
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two items per row
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length, // Number of items in the search results
      itemBuilder: (context, index) {
        final meal = _searchResults[index]; // Get the current meal
        final mealName = meal['strMeal'];
        final displayMealName = mealName;

        return Card(
          color: Theme.of(context).cardColor,
          margin: EdgeInsets.all(2.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: GestureDetector(
            onTap: () {
              // Navigate to RecipeDetailsPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailsPage(
                    recipeName: meal['strMeal'],
                    categoryName: meal['strCategory'],
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(3.w),
                    topRight: Radius.circular(3.w),
                  ),
                  child: Image.network(
                    meal['strMealThumb'], // Display meal thumbnail
                    height: 14.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(1.w),
                  child: Text(
                    displayMealName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).backgroundColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Prevent text overflow
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        meal['strCategory'], // Display meal category
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      FavoriteWidget(recipeId: meal['idMeal'], recipeName: meal['strCategory']), // Favorite widget
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
