import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';
import 'package:magic_cook1/screens/faviourtPage/favoriteScreen.dart';
import 'package:magic_cook1/screens/setting/settingScreen.dart';
import 'package:magic_cook1/screens/shoppingList/shoppingList.dart';

class profileScreen extends StatefulWidget {
  const profileScreen({super.key});

  @override
  State<profileScreen> createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children:[
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/profileScreen.jpeg"),
                ),
              ),
            ),
            // Positioned.fill container
            Positioned.fill(
              child: Container(
                color: Theme.of(context).shadowColor,
              ),
            ),
            SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 1, 0, 50),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Container(
                child: Stack(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon:  Icon(
                            Icons.arrow_back,
                            color: Colors.amber.shade900,
                            size: 40,
                          ),
                          onPressed: () {
                             Navigator.pop(context);
                          },
                        ),
                        SizedBox(width: 10,),
                        Text(
                          AppLocalizations.of(context)!.profile_title,
                          style: TextStyle(
                              fontSize: 35,
                              color: Theme.of(context).primaryColor,
                              fontFamily: "fonts/Raleway-Bold"),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50,),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          width: double.infinity,
                          height: 250,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 10,
                                right: 10,
                                top: 50,
                                child: Align(
                                  child: SizedBox(
                                    width: 290,
                                    height: 170,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color:  Theme.of(context).cardColor,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x3f000000),
                                            offset: Offset(0, 4),
                                            blurRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 10,
                                right: 10,
                                top: 80,
                                child: Align(
                                  child: SizedBox(
                                    width: 94,
                                    height: 94,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(47),
                                        border: Border.all(
                                            color: const Color(0xff000000)),
                                        image: const DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            "assets/Ellipse 2 (1).png",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 10,
                                right: 10,
                                top: 170,
                                child: Align(
                                  child: SizedBox(
                                    width: 114,
                                    height: 31,
                                    child: Text(
                                      'Jennaxx1',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2125,
                                        color:Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 38),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildIconButton(
                                "assets/favLight.png",
                                AppLocalizations.of(context)!.favorite,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FavoritesPage()),
                                ),
                              ),
                              _buildIconButton(
                                "assets/Shopping cart Light.png",
                                AppLocalizations.of(context)!.shopping_list,
                                    () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => shoppingList(recipeName: '',)),
                                ),
                              ),
                              SettingButton(),
                              _buildIconButton(
                                  "assets/LogoutLight.png",
                                  AppLocalizations.of(context)!.logout,
                                      () {}),
                            ],
                          ),
                        ),
                      //  SizedBox(height: 250,)
                      ],
                    ),
                    SizedBox(height: 900,)
                  ],
                ),
              ),

            ),
          ),
       ] ),
      ),
    );
  }

  Widget _buildIconButton(
      String imagePath, String text, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor,),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.only(right: 15),
            width: 45,
            height: 42,
            child: Image.asset(
              imagePath,
              width: 45,
              height: 42,
              color: Theme.of(context).primaryColor,
            ),
          ),
          TextButton(
            onPressed: () {
              onPressed();
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              text,
              style:  TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 1.2125,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
