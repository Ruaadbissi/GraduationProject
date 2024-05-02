import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MealPlanningRecipePreferences {
  static const _keyRecipeName = 'mealPlanningRecipeName';
  static const _keyEvents = 'mealPlanningEvents';

  // Retrieve the recipe name from shared preferences
  static Future<String?> getRecipeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRecipeName);
  }

  // Save the recipe name to shared preferences
  static Future<void> saveRecipeName(String recipeName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRecipeName, recipeName);
  }

  // Retrieve the events map from shared preferences
  static Future<Map<DateTime, List<String>>> getEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? eventsString = prefs.getString(_keyEvents);
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

  // Save the events map to shared preferences
  static Future<void> saveEvents(Map<DateTime, List<String>> events) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> eventsMap = {};
    events.forEach((key, value) {
      eventsMap[key.toString()] = value;
    });
    String eventsString = jsonEncode(eventsMap);
    await prefs.setString(_keyEvents, eventsString);
  }

  // Add a recipe to a specific date
  static Future<void> addRecipe(DateTime date, String recipeName) async {
    Map<DateTime, List<String>> events = await getEvents();
    events.update(date, (recipes) => [...recipes, recipeName], ifAbsent: () => [recipeName]);
    await saveEvents(events);
  }

  // Remove a recipe from a specific date
  static Future<void> removeRecipe(DateTime date, String recipeName) async {
    Map<DateTime, List<String>> events = await getEvents();
    events.update(date, (recipes) => recipes..remove(recipeName), ifAbsent: () => []);
    await saveEvents(events);
  }
}
