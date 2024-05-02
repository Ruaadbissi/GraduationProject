

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_translate/google_translate.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_translate/google_translate.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_translate/google_translate.dart';
import 'package:google_translate/google_translate.dart';
import 'package:translator/translator.dart';

// class TranslationService {
//   final GoogleTranslator _translator = GoogleTranslator();
//
//   Future<String> translate(String text, String toLanguage) async {
//     final translation = await _translator.translate(text, to: toLanguage);
//     return translation.text;
//   }




class TranslationService {
  static Future<String> translate(String text, String targetLanguage) async {
    GoogleTranslator translator = GoogleTranslator();
    Translation translation = await translator.translate(text, to: targetLanguage);
    String translatedText = translation.text;
    return translatedText;
  }
}



// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   String _translatedText = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _translateApp();
//   }
//
//   Future<void> _translateApp() async {
//     // Fetch text data from your API
//     String apiUrl = 'https://api.example.com/data'; // Replace with your API endpoint
//     var response = await http.get(Uri.parse(apiUrl));
//
//     if (response.statusCode == 200) {
//       // Parse and extract text data from the API response
//       String textData = response.body;
//
//       // Translate text data using the Google Translate API
//       GoogleTranslate translator = GoogleTranslate();
//       String translatedText = await translator.translate(
//         textData,
//         "ar", // Translate to Arabic, you can change the target language
//       );
//
//       // Update the UI with the translated text
//       setState(() {
//         _translatedText = translatedText;
//       });
//     } else {
//       // Handle API error
//       print('Failed to fetch data from API: ${response.statusCode}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Translated App'),
//         ),
//         body: Center(
//           child: Text(_translatedText),
//         ),
//       ),
//     );
//   }
// }

