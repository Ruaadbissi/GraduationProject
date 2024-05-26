import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:magic_cook1/screens/recipesList/recipesList.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';

import '../search_screen/search_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final apiUrl = 'https://www.themealdb.com/api/json/v1/1/categories.php';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final categoryList = List<Map<String, dynamic>>.from(data['categories'].map((category) => {
        'name': category['strCategory'],
        'image': category['strCategoryThumb'],
      }));
      return categoryList;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  void _navigateToSelectedCategoryScreen(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeListScreen(category: category),
      ),
    );
  }

  Widget _buildCategoryButton(BuildContext context, String category, String imageUrl) {
    return GestureDetector(
      onTap: () {
        _navigateToSelectedCategoryScreen(category);
      },
      child: Container(
        margin:  EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(3.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(3.w)),
              child: Padding(
                padding:  EdgeInsets.all(2.w),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 12.h,
                  width: 15.w,
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.all(4.w),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              padding:  EdgeInsets.symmetric(horizontal: 1.w),
              child: Stack(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for recipe',
                      hintStyle: TextStyle(color: Theme.of(context).hintColor,fontSize: 15.sp),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor,size: 4.h),
                      border: InputBorder.none,
                    ),
                  ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:  Theme.of(context).primaryColor,
            size: 5.h,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 2.h),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Categories',
                style: TextStyle(
                  color:  Theme.of(context).backgroundColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).backgroundColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final categories = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return _buildCategoryButton(
                          context,
                          categories[index]['name'],
                          categories[index]['image'],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
