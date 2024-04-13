import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/faviourtPage/favoriteScreen.dart';
import 'package:magic_cook1/screens/homeScreen/homeScreen.dart';
import 'package:magic_cook1/screens/profileScreen/profileScreen.dart';
import 'package:magic_cook1/screens/shoppingList/shoppingList.dart';
import 'package:magic_cook1/screens/utils/helper/model.dart';

import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';


class navigationBar extends StatefulWidget {
  const navigationBar({Key? key}) : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<navigationBar> {
  int _currentIndex = 0;
  List<placeModel> _favoritePlaces = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabBar(),
    );
  }

  void updateFavorites(List<placeModel> favorites) {
    setState(() {
      _favoritePlaces = favorites;
    });
  }

  Widget _tabBar() {
    return PersistentTabView(
      context,
      screens: [
        homeScreen(updateFavorites: updateFavorites),
        FavoritesPage(),
        shoppingList(recipeName: '',),
        profileScreen(),
      ],
      navBarHeight: 70,
      backgroundColor: Theme.of(context).bottomAppBarColor,
      decoration: const NavBarDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      confineInSafeArea: true,
      navBarStyle: NavBarStyle.style6,
      items: [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.home),
          activeColorPrimary: _currentIndex == 0
              ?  Colors.amber.shade900
              : Theme.of(context).primaryColor,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.favorite),
          activeColorPrimary: _currentIndex == 1
              ? Colors.amber.shade900
              : Theme.of(context).primaryColor,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.shopping_cart),
          activeColorPrimary: _currentIndex == 2
              ? Colors.amber.shade900
              : Theme.of(context).primaryColor,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.person),
          activeColorPrimary: _currentIndex == 3
              ? Colors.amber.shade900
              : Theme.of(context).primaryColor,
        ),
      ],
      popActionScreens: PopActionScreensType.all,
      popAllScreensOnTapOfSelectedTab: true,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      onItemSelected: (v) {
        setState(() {
          _currentIndex = v;
        });
      },
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      popAllScreensOnTapAnyTabs: false,

    );
  }
}
