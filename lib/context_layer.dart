import 'package:flutter/material.dart';

class ContextLayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        title: Text("🌦 Context-Aware Intelligence"),
        backgroundColor: Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // HEADER TITLE
            Center(
              child: Text(
                "🌦 Context-Aware Intelligence",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 20),

            // WEATHER CARD (IMPROVED UI)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text("☀️", style: TextStyle(fontSize: 60)),

                  SizedBox(height: 10),

                  Text(
                    "36°C",
                    style: TextStyle(
                      fontSize: 42,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoBox("💧", "68%"),
                      _infoBox("👀", "Good"),
                      _infoBox("🌬", "12 km/h"),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ALERTS SECTION
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFF7C2D12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⚠ Travel Alerts",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("🌧 Rain expected within 2 hours",
                      style: TextStyle(color: Colors.orangeAccent)),
                  Text("🚧 Construction near Main Road",
                      style: TextStyle(color: Colors.orangeAccent)),
                ],
              ),
            ),

            SizedBox(height: 20),

            // IMPACT ANALYSIS
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF14532D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⏱ Commute Impact Analysis",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("🟢 Delay Risk: LOW",
                      style: TextStyle(color: Colors.greenAccent)),
                  Text("Expected Delay: +4 mins",
                      style: TextStyle(color: Colors.white70)),
                  Text("Road Conditions: Stable",
                      style: TextStyle(color: Colors.white70)),
                  Text("Transport: Running Normally",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            SizedBox(height: 20),

            // SMART RECOMMENDATION
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💡 Smart Recommendation",
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Leave within 30 minutes to avoid rainfall and ensure smooth travel.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Carry an umbrella. Weather may change later.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // SMALL WIDGET FOR CLEAN UI
  Widget _infoBox(String icon, String value) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 20)),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}