import 'package:flutter/material.dart';
import 'package:google_translate/components/google_translate.dart';
import 'package:http/http.dart' as http;
import 'package:magic_cook1/screens/recipesList/recipesList.dart';
import 'package:magic_cook1/screens/utils/ui/search/search.dart';
import 'package:translator/translator.dart';
import 'dart:convert';

import '../../translate_test.dart';

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
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 100, // Adjust the height as needed
                  width: 150, // Adjust the width as needed
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 16,
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 40,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: searchDark(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Categories',
                style: TextStyle(
                  color: Colors.amber.shade900,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
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
//translate code :
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:google_translate/google_translate.dart'; // Import the google_translate package
//
// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({Key? key}) : super(key: key);
//
//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }
//
// class _CategoriesScreenState extends State<CategoriesScreen> {
//   final TranslationService _translationService = TranslationService();
//   List<Map<String, dynamic>> _categories = [];
//   bool _loading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchCategories();
//   }
//
//   Future<void> _fetchCategories() async {
//     setState(() {
//       _loading = true;
//     });
//
//     final apiUrl = 'https://www.themealdb.com/api/json/v1/1/categories.php';
//     final response = await http.get(Uri.parse(apiUrl));
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final categoryList = List<Map<String, dynamic>>.from(
//           data['categories'].map((category) =>
//           {
//             'name': category['strCategory'],
//             'image': category['strCategoryThumb'],
//           }));
//
//       setState(() {
//         _categories = categoryList;
//         _loading = false;
//       });
//     } else {
//       setState(() {
//         _loading = false;
//       });
//       throw Exception('Failed to load categories');
//     }
//   }
//
//   void _navigateToSelectedCategoryScreen(String category) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => RecipeListScreen(category: category),
//       ),
//     );
//   }
//
//   Widget _buildCategoryButton(BuildContext context, String category,
//       String imageUrl) {
//     return GestureDetector(
//       onTap: () {
//         _navigateToSelectedCategoryScreen(category);
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         decoration: BoxDecoration(
//           color: Theme
//               .of(context)
//               .cardColor,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Image.network(
//                   imageUrl,
//                   fit: BoxFit.cover,
//                   height: 100, // Adjust the height as needed
//                   width: 150, // Adjust the width as needed
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Text(
//                 category,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Theme
//                       .of(context)
//                       .primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Categories'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.language),
//             onPressed: () {
//               // Show language selection dialog
//               _showLanguageSelectionDialog();
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Theme
//           .of(context)
//           .scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Text(
//                 'Categories',
//                 style: TextStyle(
//                   color: Colors.amber.shade900,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: _loading
//                   ? Center(
//                 child: CircularProgressIndicator(),
//               )
//                   : GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 5,
//                   mainAxisSpacing: 5,
//                 ),
//                 itemCount: _categories.length,
//                 itemBuilder: (context, index) {
//                   return _buildCategoryButton(
//                     context,
//                     _categories[index]['name'],
//                     _categories[index]['image'],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   //Method to show language selection dialog
//   void _showLanguageSelectionDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Select Language'),
//           content: DropdownButton<String>(
//             value: 'en', // Set the default language to English
//             onChanged: (String? languageCode) {
//               // Handle language change
//               if (languageCode != null) {
//                 changeLanguage(languageCode); // Call changeLanguage method
//               }
//             },
//             items: <String>['en', 'ar'] // English and Arabic language codes
//                 .map
//               ((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value == 'en' ? 'English' : 'Arabic'),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
//
//   void changeLanguage(String languageCode) async {
//     // Translate category names to the selected language
//     await _translateCategories(languageCode);
//   }
//
//   Future<void> _translateCategories(String languageCode) async {
//     final List<Map<String, dynamic>> translatedCategories = [];
//
//     for (var category in _categories) {
//       final translatedName = await TranslationService.translate(category['name'], languageCode);
//       translatedCategories.add({
//         'name': translatedName,
//         'image': category['image'],
//       });
//     }
//
//     setState(() {
//       _categories = translatedCategories;
//     });
//   }
// }
