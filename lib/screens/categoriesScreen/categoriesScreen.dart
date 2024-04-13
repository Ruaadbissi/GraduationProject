import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/recipesList/recipesList.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:magic_cook1/screens/utils/ui/search/search.dart';

class categoriesScreen extends StatelessWidget {
  const categoriesScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body)['categories']);
    } else {
      throw Exception('Failed to load categories');
    }
  }
  Widget buildCategoryButtons(BuildContext context, List<Map<String, dynamic>> categories) {
    List<Widget> rows = [];
    for (int i = 0; i < categories.length; i += 2) {
      // Create a row with two categories
      Widget row = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildCategoryButton(context, categories[i]['strCategory'], categories[i]['strCategoryThumb']),
          if (i + 1 < categories.length)
            buildCategoryButton(context, categories[i + 1]['strCategory'], categories[i + 1]['strCategoryThumb']),
        ],
      );
      rows.add(row);
    }
    return Column(
      children: rows,
    );
  }

  Widget buildCategoryButton(BuildContext context, String name, String imagePath) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 4, 0),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => recipesList(categoryName: name),
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Container(
          width: 200,
          height: 150,
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 5, 1, 2),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width:  MediaQuery.of(context).size.width,
                  height:  85,
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.72,
                  child: searchDark(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final categories = snapshot.data!;
                    return SingleChildScrollView(
                      child: buildCategoryButtons(context, categories),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

}
