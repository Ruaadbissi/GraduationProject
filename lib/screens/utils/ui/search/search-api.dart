import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeSearch {
  static Future<List<dynamic>> searchRecipes(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/search.php?s=$query'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['meals'];
    } else {
      throw Exception('Failed to search recipes');
    }
  }
}