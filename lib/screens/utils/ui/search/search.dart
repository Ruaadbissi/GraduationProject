import 'package:flutter/material.dart';
import 'package:magic_cook1/l10n/app_localizations.dart';

class searchDark extends StatefulWidget {
  const searchDark({Key? key}) : super(key: key);

  @override
  State<searchDark> createState() => _searchState();
}

class _searchState extends State<searchDark> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).primaryColor,),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.search,
                  hintStyle: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Theme.of(context).primaryColor,)
                  //Color(0xFF7B7B7B),
                  ,
                  suffixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          // SizedBox(height: 16),
          // Text('Search Result: $_searchResult'),
        ],
      ),
    );
  }
}
