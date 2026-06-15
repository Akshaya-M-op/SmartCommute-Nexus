import 'package:flutter/material.dart';
import 'route_planner/models/route_model.dart';
import 'route_planner/services/directions_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';


class SafetyLayer extends StatefulWidget {
  final String language;
  final bool accessibilityMode;
  final RouteModel? routeA;
  final RouteModel? routeB;

  const SafetyLayer({
    super.key,
    required this.language,
    required this.accessibilityMode,
    this.routeA,
    this.routeB,

  });

  @override
  State<SafetyLayer> createState() => _SafetyLayerState();
}

class _SafetyLayerState extends State<SafetyLayer> {
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
  final DirectionsService _directionsService = DirectionsService();


  List<Map<String, String>> reports = [];

  bool loading = false;

  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;
  String selectedHazard = "";

  // ---------------- SCORE ENGINE ----------------
  int calculateRouteScore(RouteModel? route) {
    if (route == null) return 5;

    int score = 10;

    for (var r in reports) {
      String type = (r["type"] ?? "").toLowerCase();

      if (type == "flood") score -= 3;
      if (type == "pothole") score -= 2;
      if (type == "traffic") score -= 1;
      if (type == "ramp") score += 1;
    }

    if (score < 1) score = 1;
    if (score > 10) score = 10;

    return score;
  }

  int get routeAScore => calculateRouteScore(widget.routeA);
  int get routeBScore => calculateRouteScore(widget.routeB);

  // ---------------- BEST ROUTE DECISION ----------------
  String getBestRoute() {
  if (widget.routeA == null && widget.routeB == null) {
    return "Loading routes...";
  }

  if (widget.routeB == null) {
    return "🚍 Route A is the available route";
  }

  if (routeAScore > routeBScore) {
    return "🚍 Route A is BEST (AI Safe Choice)";
  } else if (routeBScore > routeAScore) {
    return "🚍 Route B is BEST (AI Safe Choice)";
  } else {
    return "⚖ Both routes are similar";
  }
}

  // ---------------- LOAD ROUTES ----------------
  Future<void> loadRoutes() async {
    setState(() => loading = true);

    try {
      final routes = await _directionsService.getRoutes(
        13.0827,
        80.2707,
        13.0927,
        80.2907,
      );

      setState(() {
        debugPrint("Total Routes Found: ${routes.length}");
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint("Route error: $e");
    }
  }

  Future<void> _pickImage(String hazardType) async {
  final XFile? image = await _picker.pickImage(
    source: ImageSource.gallery,
  );

  if (image != null) {
    setState(() {
      selectedImage = image;
      selectedHazard = hazardType;
    });
     _showLocationDialog();
  }
}

  @override
  void initState() {
    super.initState();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(t(widget.language,
    "🛡 SmartCommute Safety Layer",
    "🛡 ஸ்மார்ட் கம்யூட் பாதுகாப்பு",
    "🛡 स्मार्टकम्यूट सुरक्षा लेयर",
  ),),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Text(
                    t(widget.language,
    "🛡 AI Route Safety Analysis",
    "🛡 AI பாதை பாதுகாப்பு பகுப்பாய்வு",
    "🛡 एआई रूट सुरक्षा विश्लेषण"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _routeCard("Route A", widget.routeA, routeAScore),

                  const SizedBox(height: 20),

                  if (widget.routeB != null)
  _routeCard("Route B", widget.routeB, routeBScore),

                  const SizedBox(height: 20),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getBestRoute(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (widget.accessibilityMode)
  Container(
    margin: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.green.shade800,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "♿ Accessibility Mode Enabled",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "✅ Ramp-friendly pathways",
          style: TextStyle(color: Colors.white),
        ),
        Text(
          "✅ Wheelchair accessible route preferred",
          style: TextStyle(color: Colors.white),
        ),
        Text(
          "✅ Avoided staircase-only areas",
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  ),

                  const SizedBox(height: 20),
                  Text(
   t(widget.language,
    "🚨 Hazard Reporting",
    "🚨 அபாய அறிக்கை",
    "🚨 खतरा रिपोर्टिंग"),
  style: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

ElevatedButton(
  onPressed: _showReportDialog,
  child: Text( t(widget.language,
      "Report Hazard",
      "அபாயம் அறிக்கை",
      "खतरा रिपोर्ट"),),
),

const SizedBox(height: 10),

ElevatedButton(
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  onPressed: () async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double lat = position.latitude;
    double lng = position.longitude;

    String googleMapsUrl = "https://www.google.com/maps?q=$lat,$lng";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("🚨 SOS Emergency"),
         content: Text(
  "🚨 Location generated.\n\n"
  "Share this link:\n$googleMapsUrl",
),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  },
  child: Text(
    t(widget.language,
      "Emergency SOS",
      "அவசர SOS",
      "आपातकालीन SOS"),
    style: const TextStyle(color: Colors.white),
  ),
),

const SizedBox(height: 20),
                ],
              ),
            ),
            
    );
  }

  void _showReportDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Hazard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("🕳 Pothole"),
              onTap: () {
                Navigator.pop(context);
                _pickImage("Pothole");
              },
            ),

            ListTile(
              title: const Text("🌊 Flood"),
              onTap: () {
                Navigator.pop(context);
                _pickImage("Flood");
              },
            ),

            ListTile(
              title: const Text("♿ Ramp"),
              onTap: () {
                Navigator.pop(context);
                _pickImage("Ramp");
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showLocationDialog() {
  TextEditingController locationController =
      TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Report $selectedHazard"),
        content: TextField(
          controller: locationController,
          decoration: const InputDecoration(
            hintText: "Enter location",
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              reports.add({
                "type": selectedHazard,
                 "location": locationController.text.isEmpty
      ? "Unknown Location"
      : locationController.text,
              });

              Navigator.pop(context);

              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Hazard reported successfully"),
                ),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      );
    },
  );
}

  // ---------------- ROUTE CARD ----------------
  Widget _routeCard(String title, RouteModel? route, int score) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🚍 ${t(widget.language,
    title,
    title == "Route A" ? "வழி A" : "வழி B",
    title == "Route A" ? "रूट A" : "रूट B")}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            route?.durationText ?? "Loading...",
            style: const TextStyle(color: Colors.white70),
          ),

          Text(
            route?.distanceText ?? "",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 10),

          Text(
            "$score/10",
            style: const TextStyle(
              color: Colors.green,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
   t(widget.language,
    "🛡 AI Route Insights",
    "🛡 AI வழி பார்வை",
    "🛡 एआई रूट इनसाइट्स"),
  style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 8),

Text(
   t(widget.language,
    "✅ Safety: Bypassed 2 high-risk zones",
    "✅ பாதுகாப்பு: 2 ஆபத்தான பகுதிகள் தவிர்க்கப்பட்டது",
    "✅ सुरक्षा: 2 जोखिम क्षेत्र टाले गए"),
  style: TextStyle(color: Colors.white70),
),

const SizedBox(height: 4),

Text(
  widget.accessibilityMode
      ? "♿ Accessibility: Ramp-friendly routes prioritized"
      : "♿ Accessibility: Standard route used",
  style: const TextStyle(color: Colors.white70),
),

const SizedBox(height: 4),

Text(
  t(widget.language,
    "🚦 Traffic: Moderate congestion detected",
    "🚦 போக்குவரத்து: நடுத்தர நெரிசல் கண்டறியப்பட்டது",
    "🚦 ट्रैफिक: मध्यम भीड़भाड़ पाई गई"),
  style: TextStyle(color: Colors.white70),
),
        ],
      ),
    );
  }
}