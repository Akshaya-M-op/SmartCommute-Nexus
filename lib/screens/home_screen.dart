import 'package:flutter/material.dart';
import 'package:smartcommute/safety_layer.dart';
import 'package:smartcommute/context_layer.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),

      appBar: AppBar(
        title: Text("SmartCommute-Nexus"),
        centerTitle: true,
        backgroundColor: Color(0xFF1E293B),
      ),

      body: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER CARD
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "🚀 Welcome to SmartCommute-Nexus",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 14),

            Text(
              "Dashboard",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            SizedBox(height: 12),

            // GRID MENU
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: [

                  _buildCard(
                    context,
                    "🗺 Route Planner",
                    "Find best routes",
                    Colors.blue,
                    () {
                      // future screen
                    },
                  ),

                  _buildCard(
                    context,
                    "🛡 Safety Layer",
                    "Report & SOS",
                    Colors.red,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SafetyLayer(),
                        ),
                      );
                    },
                  ),

                  _buildCard(
                    context,
                    "🌦 Context Aware",
                    "Weather alerts",
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContextLayer(),
                        ),
                      );
                    },
                  ),

                  _buildCard(
                    context,
                    "💬 Feedback",
                    "User input",
                    Colors.green,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Feedback screen coming soon")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CARD ----------------
  Widget _buildCard(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),

      child: InkWell(
        onTap: onTap,

        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 6),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}