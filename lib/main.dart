import 'package:flutter/material.dart';
import 'screens/language_access_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // THIS IS YOUR FIRST SCREEN
      home: LanguageAccessScreen(),
    );
  }
}