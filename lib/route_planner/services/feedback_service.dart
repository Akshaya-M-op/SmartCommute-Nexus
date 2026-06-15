import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedbackService {
  final String baseUrl = "http://192.168.31.160:5000/api/feedback";

  // -----------------------------------
  // 1. GET NEARBY INCIDENTS
  // -----------------------------------
  Future<List<dynamic>> getNearbyIncidents() async {
    final url = Uri.parse("$baseUrl/nearby");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  // -----------------------------------
  // 2. POST NEW REPORT
  // -----------------------------------
  Future<bool> sendReport({
    required String title,
    required String category,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse("$baseUrl/report");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "category": category,
        "latitude": latitude,
        "longitude": longitude,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // -----------------------------------
  // 3. VERIFY / UPVOTE INCIDENT
  // -----------------------------------
  Future<bool> verifyIncident(String reportId) async {
    final url = Uri.parse("$baseUrl/verify");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "reportId": reportId,
      }),
    );

    return response.statusCode == 200;
  }
}