import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// Class for managing meal planning recipe preferences
class MealPlanningRecipePreferences {
  // Prefix for storing events in SharedPreferences
  static const _keyEventsPrefix = 'mealPlanningEvents';

  // Method to get meal planning events from SharedPreferences
  static Future<Map<DateTime, List<String>>> getEvents(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? eventsString = prefs.getString('$_keyEventsPrefix-$uid');
    Map<DateTime, List<String>> events = {};

    if (eventsString != null && eventsString.isNotEmpty) {
      Map<String, dynamic> eventsMap = jsonDecode(eventsString);
      eventsMap.forEach((key, value) {
        DateTime date = DateTime.parse(key);
        List<String> recipes = List<String>.from(value);
        events[date] = recipes;
      });
    }
    return events;
  }

  // Method to save meal planning events to SharedPreferences and Firestore
  static Future<void> saveEvents(Map<DateTime, List<String>> events, String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> eventsMap = {};
    events.forEach((key, value) {
      eventsMap[key.toIso8601String()] = value;
    });
    String eventsString = jsonEncode(eventsMap);
    await prefs.setString('$_keyEventsPrefix-$uid', eventsString);

    await _updateFirestoreEvents(events, uid);
  }

  // Method to update Firestore with meal planning events
  static Future<void> _updateFirestoreEvents(Map<DateTime, List<String>> events, String uid) async {
    try {
      List<Map<String, dynamic>> eventData = [];
      events.forEach((date, recipes) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(date);
        recipes.forEach((recipeName) {
          eventData.add({'recipeName': recipeName, 'date': formattedDate});
        });
      });

      // Update Firestore with the meal planning events data
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("mealPlanning")
          .doc('plans')
          .set({'recipes': eventData}, SetOptions(merge: true));
    } catch (error) {
      print("Error updating Firestore events: $error");
    }
  }

  // Method to add a recipe to a specific date in the meal planning events
  static Future<void> addRecipe(DateTime date, String recipeName, String uid) async {
    Map<DateTime, List<String>> events = await getEvents(uid);
    if (events.containsKey(date) && !events[date]!.contains(recipeName)) {
      events[date]!.add(recipeName);
    } else if (!events.containsKey(date)) {
      events[date] = [recipeName];
    }
    await saveEvents(events, uid);
  }

  // Method to remove a recipe from a specific date in the meal planning events
  static Future<void> removeRecipe(DateTime date, String recipeName, String uid) async {
    Map<DateTime, List<String>> events = await getEvents(uid);
    if (events.containsKey(date)) {
      events[date]!.remove(recipeName);
      if (events[date]!.isEmpty) {
        events.remove(date);
      }
    }
    await saveEvents(events, uid);
  }

  // Method to clear the meal planning calendar
  static Future<void> clearCalendar(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyEventsPrefix-$uid');

    // Delete the meal planning document from Firestore
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection("mealPlanning")
        .doc('plans')
        .delete();
  }
}
