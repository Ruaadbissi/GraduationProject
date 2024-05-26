import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:oktoast/oktoast.dart';
import 'package:magic_cook1/screens/utils/helper/userProvider.dart';
import 'package:magic_cook1/screens/detailsScreen/detailsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:magic_cook1/screens/utils/helper/planning/mealPlanningPref.dart';

// Define a stateful widget for meal planning
class MealPlanningScreen extends StatefulWidget {
  final String? recipeName; // Recipe name to be added to the calendar
  final bool showLeadingArrow; // Option to show back arrow in AppBar

  MealPlanningScreen({Key? key, this.recipeName, this.showLeadingArrow = false})
      : super(key: key);

  @override
  _MealPlanningScreenState createState() => _MealPlanningScreenState();
}

// Define the state for the meal planning widget
class _MealPlanningScreenState extends State<MealPlanningScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month; // Initial calendar format
  DateTime _focusedDay = DateTime.now(); // Initially focused day
  DateTime? _selectedDay; // Currently selected day
  late UserProvider _userProvider; // Provider to manage user data
  Map<DateTime, List<String>> _events = {}; // Map to store events

  @override
  void initState() {
    super.initState();
    _getUserData(); // Call to check user data
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context);
    if (_userProvider.userName != "Guest User") {
      _getEventsData(); // Load events if the user is not a guest
    }
  }

  // Fetch events data from preferences
  Future<void> _getEventsData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      final events = await MealPlanningRecipePreferences.getEvents(user.uid);
      setState(() {
        _events.clear();
        _events.addAll(events); // Add fetched events to the map
      });
    }
  }

  // Get user data and clear calendar if the user is a guest
  Future<void> _getUserData() async {
    _userProvider = Provider.of<UserProvider>(context);
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous && _userProvider.userName == "Guest User") {
      await MealPlanningRecipePreferences.clearCalendar(user.uid);
      setState(() {
        _events = {}; // Clear events
      });
    }
  }

  // Add a recipe to the calendar
  Future<void> _addRecipeToCalendar(DateTime selectedDay, String recipeName) async {
    final DateTime currentDate = DateTime.now();

    // Prevent adding recipes to past dates
    if (selectedDay.isBefore(currentDate)) {
      _showToast("You can't go back in time to cook that!");
      return;
    }

    // Prevent adding the same recipe multiple times to the same day
    if (_events.containsKey(selectedDay) && _events[selectedDay]!.contains(recipeName)) {
      _showToast("Recipe already added for this day");
      return;
    }

    // Update state to include the new event
    setState(() {
      if (_events.containsKey(selectedDay)) {
        _events[selectedDay]!.add(recipeName);
      } else {
        _events[selectedDay] = [recipeName];
      }
    });

    // Save the event to preferences if the user is not anonymous
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      await MealPlanningRecipePreferences.addRecipe(selectedDay, recipeName, user.uid);
    }
    _showToast('Recipe added successfully');
  }

  // Navigate to the recipe details page
  void _viewRecipeDetails(String recipeName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsPage(
          recipeName: recipeName,
          categoryName: '',
        ),
      ),
    ).then((value) {
      // Add recipe to calendar upon returning if a recipe was selected
      if (value != null && value is String) {
        _addRecipeToCalendar(_selectedDay ?? DateTime.now(), value);
      }
    });
  }

  // Function to show toast messages
  void _showToast(String message) {
    showToast(
      message,
      duration: Duration(seconds: 2),
      position: ToastPosition.bottom,
      backgroundColor: Colors.amber.shade900,
      radius: 8.0,
      textStyle: TextStyle(fontSize: 16.0, color: Colors.black),
    );
  }

  // Build a list of event widgets for a given day
  List<Widget> _buildEventsForDay(DateTime date) {
    List<Widget> eventWidgets = [];

    // Do not show events for guest users
    if (_userProvider.userName == "Guest User") {
      return eventWidgets;
    }

    // Build event widgets for the given date
    if (_events.containsKey(date)) {
      _events[date]!.forEach((recipeName) {
        eventWidgets.add(
          Dismissible(
            key: Key(recipeName), // Key for dismissible widget
            onDismissed: (direction) {
              _removeRecipeFromCalendar(date, recipeName); // Remove recipe on swipe
            },
            background: Container(
              color: Theme.of(context).backgroundColor,
              alignment: Alignment.centerRight,
              child: Icon(Icons.delete, color: Theme.of(context).scaffoldBackgroundColor,),
            ),
            child: GestureDetector(
              onTap: () => _viewRecipeDetails(recipeName), // View recipe details on tap
              child: Center(
                child: Container(
                  width: 90.w,
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipeName,
                        style: TextStyle(
                          color: Theme.of(context).backgroundColor,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Tap to view recipe',
                        style: TextStyle(color: Theme.of(context).hintColor, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    }

    return eventWidgets;
  }

  // Remove a recipe from the calendar
  Future<void> _removeRecipeFromCalendar(DateTime date, String recipeName) async {
    if (_events.containsKey(date)) { // Checks if the _events map contains the specified date as a key
      _events[date]!.remove(recipeName); // If the date exists, it removes the recipeName from the list of recipes for that date
      if (_events[date]!.isEmpty) { // After removing the recipe, it checks if the list of recipes for that date is empty
        _events.remove(date); // If it is empty, it removes the date entry from the _events map entirely
      }
    }
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      await MealPlanningRecipePreferences.removeRecipe(date, recipeName, user.uid); // Remove from preferences
    }
    _showToast('Recipe removed successfully');
    setState(() {}); // Update state to reflect changes
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: widget.showLeadingArrow
              ? IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).primaryColor,
              size: 5.h,
            ),
            onPressed: () {
              Navigator.pop(context); // Navigate back
            },
          )
              : null,
          title: Text(
            "Meal Planning",
            style: TextStyle(
              fontSize: 25.sp,
              color: Theme.of(context).primaryColor,
              fontFamily: "fonts/Raleway-Bold",
            ),
          ),
        ),
        body: Column(
          children: [
            TableCalendar(
              key: UniqueKey(),
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2040, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day); // Highlight the selected day
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                if (_userProvider.userName != "Guest User") {
                  _addRecipeToCalendar(selectedDay, widget.recipeName!); // Add recipe to selected day
                }
              },
              eventLoader: (date) {
                return _buildEventsForDay(date); // Load events for the day
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 4,
              ),
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format; // Change calendar format
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay; // Change focused day on page change
              },
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: ListView(
                children: _selectedDay != null
                    ? _buildEventsForDay(_selectedDay!) // Display events for the selected day
                    : [],
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }
}
