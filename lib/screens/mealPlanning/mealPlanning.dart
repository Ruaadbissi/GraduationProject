import 'package:flutter/material.dart';
import 'package:magic_cook1/screens/detailsScreen/detailsScreen.dart';
import 'package:magic_cook1/screens/utils/helper/planning/mealPlanningPref.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:oktoast/oktoast.dart'; // Import oktoast package

class MealPlanningScreen extends StatefulWidget {
  final String? recipeName; // Add recipeName parameter
  MealPlanningScreen({Key? key, this.recipeName}) : super(key: key);

  @override
  _MealPlanningScreenState createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {}; // Events map to store recipe names for each date

  @override
  void initState() {
    super.initState();
    _getSavedEvents(); // Load previously saved events
  }

  // Method to retrieve saved events from SharedPreferences
  Future<void> _getSavedEvents() async {
    Map<DateTime, List<String>> events = await MealPlanningRecipePreferences.getEvents();
    setState(() {
      _events = events;
    });
  }

  // Method to add a recipe to the calendar
  Future<void> _addRecipeToCalendar(DateTime selectedDate, String recipeName) async {
    // Check if the recipe is already present for the selected date
    if (_events.containsKey(selectedDate) && _events[selectedDate]!.contains(recipeName)) {
      _showToast('Recipe already added for this date');
      return;
    }

    // Call the addRecipe method from MealPlanningRecipePreferences to save the recipe to the calendar
    await MealPlanningRecipePreferences.addRecipe(selectedDate, recipeName);

    // Refresh the events by calling _getSavedEvents
    _getSavedEvents();

    _showToast('Recipe added successfully');
  }

  void _viewRecipeDetails(String recipeName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsPage(recipeName: recipeName, categoryName: ''),
      ),
    ).then((value) {
      // Add recipe to calendar when navigating back from the details screen
      if (value != null && value is String) {
        _addRecipeToCalendar(_selectedDay ?? DateTime.now(), value);
      }
    });
  }

  void _showToast(String message) {
    showToast(
      message,
      duration: Duration(seconds: 2),
      position: ToastPosition.bottom,
      backgroundColor: Colors.black.withOpacity(0.8),
      radius: 8.0,
      textStyle: TextStyle(fontSize: 16.0, color: Colors.white),
    );
  }

  List<Widget> _buildEventsForDay(DateTime date) {
    List<Widget> eventWidgets = [];
    if (_events.containsKey(date)) {
      _events[date]!.forEach((recipeName) {
        eventWidgets.add(
          Dismissible(
            key: Key(recipeName), // Unique key for each recipe
            onDismissed: (direction) {
              _removeRecipeFromCalendar(date, recipeName);
            },
            background: Container(
              color: Colors.deepOrange,
              alignment: Alignment.centerRight,
              // padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () => _viewRecipeDetails(recipeName),
              child: Center(
                child: Container(
                  width: 365,
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipeName,
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap to view recipe',
                        style: TextStyle(color: Colors.grey),
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

// Method to remove a recipe from the calendar
  Future<void> _removeRecipeFromCalendar(DateTime date, String recipeName) async {
    // Remove the recipe from the _events map
    if (_events.containsKey(date)) {
      _events[date]!.remove(recipeName);
      if (_events[date]!.isEmpty) {
        _events.remove(date); // Remove the date entry if it has no more recipes
      }
    }

    // Call the removeRecipe method from MealPlanningRecipePreferences to remove the recipe from the calendar
    await MealPlanningRecipePreferences.removeRecipe(date, recipeName);

    // Refresh the events by calling _getSavedEvents
    _getSavedEvents();

    _showToast('Recipe removed successfully');

    // Force rebuild the widget tree to reflect the changes
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.amber.shade900,
              size: 40,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Meal Planning",
            style: TextStyle(
              fontSize: 35,
              color: Theme.of(context).primaryColor,
              fontFamily: "fonts/Raleway-Bold",
            ),
          ),
        ),
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2040, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _addRecipeToCalendar(selectedDay, widget.recipeName!);
              },
              eventLoader: (date) {
                return _buildEventsForDay(date);
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.deepOrange,
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
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            SizedBox(height:20),
            Expanded(
              child: ListView(
                children: _selectedDay != null ? _buildEventsForDay(_selectedDay!) : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
//
// class MealPlanningScreen extends StatefulWidget {
//   final String? recipeName; // Add recipeName parameter
//   MealPlanningScreen({Key? key, this.recipeName}) : super(key: key);
//
//   @override
//   _MealPlanningScreenState createState() => _MealPlanningScreenState();
// }
//
// class _MealPlanningScreenState extends State<MealPlanningScreen> {
//   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   Map<DateTime, List<String>> _events = {}; // Events map to store recipe names for each date
//
//   @override
//   void initState() {
//     super.initState();
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     tz.initializeTimeZones(); // Initialize timezones for notification scheduling
//     // Initialize other components and load saved events
//     _getSavedEvents();
//   }
//
//   Future<void> _addRecipeToCalendar(
//       DateTime selectedDate, String recipeName) async {
//     // Check if the recipe is already present for the selected date
//     if (_events.containsKey(selectedDate) &&
//         _events[selectedDate]!.contains(recipeName)) {
//       _showToast('Recipe already added for this date');
//       return;
//     }
//
//     // Call the addRecipe method from MealPlanningRecipePreferences to save the recipe to the calendar
//     //await MealPlanningRecipePreferences.addRecipe(selectedDate, recipeName);
//
//     // Refresh the events by calling _getSavedEvents
//     //_getSavedEvents();
//
//     // Schedule reminder notification
//     DateTime notificationTime =
//     selectedDate.subtract(Duration(hours: 1)); // Example: Send reminder 1 hour before the meal
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0, // Unique notification id
//       'Reminder: $recipeName', // Notification title
//       'Don\'t forget to prepare $recipeName for your meal!', // Notification body
//       tz.TZDateTime.from(notificationTime, tz.local), // Notification time
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'high_importance_channel', // Your channel id
//           'High Importance Notifications', // Your channel name
//           'This channel is used for high importance notifications.', // Channel description
//           importance: Importance.high,
//           priority: Priority.high,
//           playSound: true,
//           enableVibration: true,
//           icon: '@mipmap/ic_launcher',
//           styleInformation: BigTextStyleInformation(''), // Add a style information
//         ),
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//
//
//
//
//     _showToast('Recipe added successfully with reminder');
//   }
//
//   void _showToast(String message) {
//     // Your showToast implementation
//   }
//
//   Future<void> _getSavedEvents() async {
//     // Your implementation to load saved events
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: Colors.amber.shade900,
//             size: 40,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           "Meal Planning",
//           style: TextStyle(
//             fontSize: 35,
//             color: Theme.of(context).primaryColor,
//             fontFamily: "fonts/Raleway-Bold",
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           TableCalendar(
//             firstDay: DateTime.utc(2024, 1, 1),
//             lastDay: DateTime.utc(2040, 12, 31),
//             focusedDay: _focusedDay,
//             calendarFormat: _calendarFormat,
//             selectedDayPredicate: (day) {
//               return isSameDay(_selectedDay, day);
//             },
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDay = selectedDay;
//                 _focusedDay = focusedDay;
//               });
//               _addRecipeToCalendar(selectedDay, widget.recipeName!);
//             },
//             eventLoader: (date) {
//               return _buildEventsForDay(date);
//             },
//             calendarStyle: CalendarStyle(
//               selectedDecoration: BoxDecoration(
//                 color: Colors.deepOrange,
//                 shape: BoxShape.circle,
//               ),
//               todayDecoration: BoxDecoration(
//                 color: Colors.grey[800],
//                 shape: BoxShape.circle,
//               ),
//               markersMaxCount: 4,
//             ),
//             onFormatChanged: (format) {
//               setState(() {
//                 _calendarFormat = format;
//               });
//             },
//             onPageChanged: (focusedDay) {
//               _focusedDay = focusedDay;
//             },
//           ),
//           SizedBox(height: 20),
//           Expanded(
//             child: ListView(
//               children:
//               _selectedDay != null ? _buildEventsForDay(_selectedDay!) : [],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildEventsForDay(DateTime date) {
//     // Your implementation to build events for a day
//     return [];
//   }
// }
