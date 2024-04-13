import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
import 'package:magic_cook1/screens/categoriesScreen/categoriesScreen.dart';
import 'package:magic_cook1/screens/recipesList/recipesList.dart';
import 'package:magic_cook1/screens/utils/helper/favProvider.dart';
import 'package:magic_cook1/screens/utils/helper/model.dart';
import 'package:magic_cook1/screens/utils/ui/search/search.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class homeScreen extends StatefulWidget {
  final Function(List<placeModel>) updateFavorites;

  const homeScreen({Key? key, required this.updateFavorites}) : super(key: key);

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {

  late Future<void> _localizationFuture;
  List<placeModel> _places = [];
   List<dynamic> categories=[];

  @override
  void initState() {
    super.initState();
    _localizationFuture = initializeLocalization();
    fetchCategories();
  }

  Future<void> initializeLocalization() async {
    await Future.delayed(Duration.zero);
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['categories'];
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this._fillPlaces();
  }

  Widget build(BuildContext context) {
    FavoritePlacesProvider favoritePlacesProvider =
    Provider.of<FavoritePlacesProvider>(context, listen: false);
    return FutureBuilder<void>(
        future: _localizationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return Scaffold(
                backgroundColor: Theme
                    .of(context)
                    .scaffoldBackgroundColor,
                body: SafeArea(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      searchDark(),
                      SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(10),
                                height: 50, // Set the height of the container
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors
                                      .grey[200], // Background color of the container
                                ),

                              ),
                              SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      //"What would you like to cook today ?",
                                      AppLocalizations.of(context)!.cook_today,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: Colors.amber.shade900
                                      ),
                                    ),
                                    Text(
                                      // "Todays recommendations",
                                      AppLocalizations.of(context)!.today,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Theme
                                            .of(context)
                                            .primaryColor,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text(
                                          //"Meal Categories",
                                          AppLocalizations.of(context)!.categ,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            PersistentNavBarNavigator
                                                .pushNewScreen(
                                              context,
                                              screen: categoriesScreen(),
                                              withNavBar: true,
                                            );
                                          },
                                          child: Text(
                                            // "see all",
                                            AppLocalizations.of(context)!
                                                .see_all,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Theme
                                                  .of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              tab(categories),
                              SizedBox(height: 5,),
                              GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 1,
                                  crossAxisSpacing: 1,
                                ),
                                shrinkWrap: true,
                                itemCount: _places.length,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return View(_places[index]);
                                },
                              ),
                              SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            );
          }
        }
        );
      }

  Widget tab(List<dynamic> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map<Widget>((category) {
          return Padding(
            padding: EdgeInsets.only(left: 14.0),
            child: Container(
              height: 70,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => recipesList(categoryName: category['strCategory'])),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category['strCategory'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(width: 15),
                    Image.network(category['strCategoryThumb'], height: 50, width: 50),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget View(placeModel model) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              height: 194,
              width:  MediaQuery.of(context).size.width,
              child: InkWell(
                onTap: () {

                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8,right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          favorite(model),
                          SizedBox(
                            width: 87,
                            height: 100,
                            child: Image(
                              image: AssetImage(model.image),
                            ),
                          )
                        ],
                      ),
                      Text(
                        model.title,
                        style:  TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 11,fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        model.desc,
                        style:  TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            model.Timer,
                            style:  TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).canvasColor,
                              fontSize: 11,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Image(
                      //   image: AssetImage(model.stars),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fillPlaces() async {
    _places.clear();

    _places.add(
      placeModel("assets/Frenchtoast.png",
        // "Breakfast",
         AppLocalizations.of(context)!.breakfast,
          AppLocalizations.of(context)!.toast,
          "10 minutes",
          List.generate(5, (index) => false)),
    );
    _places.add(
      placeModel("assets/pngwing 7.png",
          //"Main Course",
           AppLocalizations.of(context)!.main_course,
          AppLocalizations.of(context)!.chicken,
          "35 minutes",
          List.generate(5, (index) => false)),
    );
    _places.add(
      placeModel(
          "assets/spanish.png",
         // "Breakfast",
          AppLocalizations.of(context)!.breakfast,
          AppLocalizations.of(context)!.omlete,
          "15 minutes",
          List.generate(5, (index) => false)),
    );
    _places.add(
      placeModel("assets/pancake.png",
         // "Breakfast",
           AppLocalizations.of(context)!.breakfast,
          AppLocalizations.of(context)!.pancake,
          "25 minutes",
          List.generate(5, (index) => false)),
    );
  }

  Widget favorite(placeModel model) {
    FavoritePlacesProvider favoriteProvider =
    Provider.of<FavoritePlacesProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        favoriteProvider.toggleFavorite(model); // Toggle favorite status
      },
      child: Center(
        child: Consumer<FavoritePlacesProvider>(
          builder: (context, favoriteProvider, child) {
            return Icon(
              favoriteProvider.isFavorite(model) ? Icons.favorite : Icons.favorite_border,
              color: favoriteProvider.isFavorite(model) ? Colors.amber.shade900 : Colors.amber.shade900,

            );
          },
        ),
      ),
    );
  }
}
