import 'package:flutter/material.dart';

class ContextLayer extends StatefulWidget {
  final String language;
  const ContextLayer({super.key,required this.language,});

  @override
  State<ContextLayer> createState() => _ContextLayerState();
}

class _ContextLayerState extends State<ContextLayer> {
  String t(String lang, String en, String ta, String hi) {
  switch (lang) {
    case "தமிழ்":
      return ta;
    case "Hindi":
      return hi;
    default:
      return en;
  }
}
  int temperature = 36;
int humidity = 68;
int windSpeed = 12;

String weatherIcon = "☀️";

String alert1 = "🌧 Rain expected within 2 hours";
String alert2 = "🚧 Construction near Main Road";

String delayRisk = "LOW";

String recommendation =
    "Leave within 30 minutes to avoid rainfall and ensure smooth travel.";
    void refreshInsights() {
  setState(() {
    temperature = 30 + (DateTime.now().second % 8);
    humidity = 60 + (DateTime.now().second % 30);
    windSpeed = 10 + (DateTime.now().second % 15);

    if (humidity > 75) {
      weatherIcon = "🌧";
      alert1 = "🌧 Rain likely soon";
      alert2 = "⚠ Wet road conditions";
      recommendation =
          "Carry an umbrella and start early.";
    } else if (temperature > 35) {
      weatherIcon = "☀️";
      alert1 = "🔥 High temperature warning";
      alert2 = "☀ Heat exposure risk";
      recommendation =
          "Carry water and avoid peak heat.";
    } else {
      weatherIcon = "⛅";
      alert1 = "✅ Weather conditions normal";
      alert2 = "🚍 Transport operating normally";
      recommendation =
          "Good conditions for travel.";
    }

    delayRisk = windSpeed > 20 ? "MEDIUM" : "LOW";
  });
}
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A),
      appBar: AppBar(
        title: Text( t(widget.language,
    "🌦 Context-Aware Intelligence",
    "🌦 சூழல் அறிவு",
    "🌦 संदर्भ आधारित बुद्धिमत्ता"),),
        backgroundColor: Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // HEADER TITLE
            Center(
              child: Text(
                t(widget.language,
    "🌦 Context-Aware Intelligence",
    "🌦 சூழல் அறிவு",
    "🌦 संदर्भ आधारित बुद्धिमत्ता"),
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
                  Text(
  weatherIcon,
  style: TextStyle(fontSize: 60),
),

                  SizedBox(height: 10),

                  Text(
                    "$temperature°C",
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
                      _infoBox("💧", "$humidity%"),
                      _infoBox("👀", "Good"),
                      _infoBox("🌬", "$windSpeed km/h"),
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
                     t(widget.language,
    "⚠ Travel Alerts",
    "⚠ பயண எச்சரிக்கைகள்",
    "⚠ यात्रा अलर्ट"),
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
  t(widget.language, alert1, alert1, alert1),
  style: TextStyle(color: Colors.orangeAccent),
),
                  Text(
  t(widget.language, alert2, alert2, alert2),
  style: TextStyle(color: Colors.orangeAccent),
),
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
                    t(widget.language,
    "⏱ Commute Impact Analysis",
    "⏱ பயண தாக்க பகுப்பாய்வு",
    "⏱ यात्रा प्रभाव विश्लेषण"),
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(t(widget.language,
    "🟢 Delay Risk: $delayRisk",
    "🟢 தாமத ஆபத்து: $delayRisk",
    "🟢 देरी जोखिम: $delayRisk"),
                      style: TextStyle(color: Colors.greenAccent)),
                  Text(t(widget.language,
    "Expected Delay: +4 mins",
    "எதிர்பார்க்கப்படும் தாமதம்: +4 நிமிடம்",
    "अनुमानित देरी: +4 मिनट"),
                      style: TextStyle(color: Colors.white70)),
                  Text( t(widget.language,
    "Road Conditions: Stable",
    "சாலை நிலை: நிலையானது",
    "सड़क स्थिति: स्थिर"),
                      style: TextStyle(color: Colors.white70)),
                  Text(t(widget.language,
    "Transport: Running Normally",
    "போக்குவரத்து: வழக்கமாக இயங்குகிறது",
    "परिवहन: सामान्य रूप से चल रहा है"),
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
                     t(widget.language,
    "💡 Smart Recommendation",
    "💡 புத்திசாலி பரிந்துரை",
    "💡 स्मार्ट सुझाव"),
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    t(widget.language, recommendation, recommendation, recommendation),
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Carry an umbrella. Weather may change later.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 15),

ElevatedButton.icon(
  onPressed: refreshInsights,
  icon: const Icon(Icons.refresh),
  label: const Text("Refresh Insights"),
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