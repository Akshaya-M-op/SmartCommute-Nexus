import 'package:flutter/material.dart';
import 'home_screen.dart';

class LanguageAccessScreen extends StatefulWidget {
  @override
  State<LanguageAccessScreen> createState() => _LanguageAccessScreenState();
}

class _LanguageAccessScreenState extends State<LanguageAccessScreen> {
  String selectedLanguage = "English";
  bool accessibilityMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // TITLE
            Text(
              "🌐 Choose Language",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            // LANGUAGE OPTIONS
            _languageTile("English"),
            _languageTile("தமிழ்"),
            _languageTile("Hindi"),

            SizedBox(height: 30),

            // ACCESSIBILITY TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "♿ Accessibility Mode",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Switch(
                  value: accessibilityMode,
                  onChanged: (value) {
                    setState(() {
                      accessibilityMode = value;
                    });
                  },
                )
              ],
            ),

            SizedBox(height: 40),

            // CONTINUE BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                );
              },
              child: Text(
                "Continue → Home",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LANGUAGE TILE WIDGET
  Widget _languageTile(String lang) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = lang;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          color: selectedLanguage == lang
              ? Colors.green
              : Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          lang,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}