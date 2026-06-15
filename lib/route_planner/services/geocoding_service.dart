import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/place_model.dart';

class GeocodingService {
  // SEARCH places (IMPORTANT: name must be searchPlaces)
  Future<List<PlaceModel>> searchPlaces(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body) as List;

    return data.map((e) => PlaceModel.fromNominatim(e)).toList();
  }

  // reverse geocode (used for current location)
  Future<String> reverseGeocode(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return 'Unknown location';
    }

    final data = jsonDecode(response.body);
    return data['display_name'] ?? 'Unknown location';
  }
}