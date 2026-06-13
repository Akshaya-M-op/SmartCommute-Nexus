import 'package:flutter/material.dart';

class SafetyLayer extends StatefulWidget {
  @override
  State<SafetyLayer> createState() => _SafetyLayerState();
}

class _SafetyLayerState extends State<SafetyLayer> {
  List<Map<String, String>> reports = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        title: Text("🛡 SmartCommute Safety Layer"),
        backgroundColor: Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // TITLE
            Center(
              child: Text(
                "🛡 SmartCommute Safety Layer",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 20),

            // ROUTE CARD
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🚍 Route A",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text("⏱ Time: 25 mins",
                      style: TextStyle(color: Colors.white70)),
                  Text("💰 Cost: ₹20",
                      style: TextStyle(color: Colors.white70)),

                  SizedBox(height: 10),

                  Text(
                    "9/10",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "🛡 VERIFIED SAFE ROUTE",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  Text("✅ Well-Lit Roads",
                      style: TextStyle(color: Colors.white70)),
                  Text("✅ No Flood Reports",
                      style: TextStyle(color: Colors.white70)),
                  Text("✅ Wheelchair Friendly",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            SizedBox(height: 20),

            // WARNING
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF3B2F12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "⚠ Minor Traffic Slowdown Ahead (+4 mins)",
                style: TextStyle(color: Color(0xFFFACC15)),
              ),
            ),

            SizedBox(height: 20),

            // INSIGHTS
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF111827),
                borderRadius: BorderRadius.circular(15),
                border: Border(
                  left: BorderSide(color: Colors.green, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "📊 Route Insights",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text("🛡 Safety: Bypassed 2 high-risk zones",
                      style: TextStyle(color: Colors.white70)),
                  Text("♿ Accessibility: Ramp-friendly pathways confirmed",
                      style: TextStyle(color: Colors.white70)),
                  Text("⛈ Context Alert: Avoided waterlogged road segments",
                      style: TextStyle(color: Colors.white70)),
                  Text("🚦 Traffic Impact: Only +4 minutes delay",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            SizedBox(height: 20),

            // HAZARD SECTION TITLE
            Text(
              "🚨 Hazard Reporting",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            // HAZARD BUTTONS (WITH LOGIC)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _hazardBox("🕳 Pothole"),
                _hazardBox("🌊 Flood"),
                _hazardBox("♿ Ramp"),
              ],
            ),

            SizedBox(height: 20),

            // REPORT HAZARD BUTTON
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _showReportDialog,
                child: Text(
                  "🚨 Report Hazard",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),

            // SOS BUTTON
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _triggerSOS,
                child: Text(
                  "🆘 Emergency SOS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ---------------- HAZARD BOX ----------------
  Widget _hazardBox(String text) {
    return GestureDetector(
      onTap: () {
        _showReportDialog();
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF334155),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ---------------- REPORT DIALOG ----------------
  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1E293B),
          title: Text(
            "🚨 Report Hazard",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("🕳 Pothole",
                    style: TextStyle(color: Colors.white)),
                onTap: () => _submitReport("Pothole"),
              ),
              ListTile(
                title: Text("🌊 Flood",
                    style: TextStyle(color: Colors.white)),
                onTap: () => _submitReport("Flood"),
              ),
              ListTile(
                title: Text("♿ Ramp",
                    style: TextStyle(color: Colors.white)),
                onTap: () => _submitReport("Ramp"),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- SUBMIT REPORT ----------------
  void _submitReport(String type) {
    Navigator.pop(context);

    setState(() {
      reports.add({
        "type": type,
        "location": "Auto Location Captured"
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Report submitted: $type")),
    );
  }

  // ---------------- SOS ----------------
  void _triggerSOS() {
    String fakeLocation = "Lat: 13.0827, Lng: 80.2707";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade900,
          title: Text(
            "🆘 Emergency SOS",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Location Shared:\n$fakeLocation\n\nEmergency contacts notified (mock)",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK",
                  style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }
}