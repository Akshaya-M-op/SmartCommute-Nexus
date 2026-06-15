import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_model.dart';

class DirectionsService {
  static const String _base = 'http://router.project-osrm.org/route/v1/driving';

  /// Fetches up to 3 routes between two points using GeoJSON geometry.
  /// GeoJSON avoids all polyline encoding precision issues — coordinates
  /// are plain [longitude, latitude] number arrays.
  Future<List<RouteModel>> getRoutes(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    final url = '$_base/$startLng,$startLat;$endLng,$endLat'
        '?overview=full&geometries=geojson&alternatives=true';

    debugPrint('OSRM request: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'SmartRoutePlanner/1.0'},
    );

    if (response.statusCode != 200) {
      throw Exception('Route fetch failed (HTTP ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final code = data['code'] as String?;
    if (code != 'Ok') {
      throw Exception('OSRM returned error: $code');
    }

    final routeList = data['routes'] as List<dynamic>;
    if (routeList.isEmpty) throw Exception('No routes found');

    final labels = ['Fastest', 'Alternative 1', 'Alternative 2'];
    final result = <RouteModel>[];

    for (int i = 0; i < routeList.length; i++) {
      final r = routeList[i] as Map<String, dynamic>;

      // GeoJSON LineString geometry: {"type":"LineString","coordinates":[[lng,lat],...]}
      final geom = r['geometry'] as Map<String, dynamic>;
      final coords = geom['coordinates'] as List<dynamic>;

      final points = coords.map((c) {
        final pair = c as List<dynamic>;
        final lng = (pair[0] as num).toDouble();
        final lat = (pair[1] as num).toDouble();
        return LatLng(lat, lng);
      }).toList();

      debugPrint('Route $i "${labels[i < labels.length ? i : 0]}": '
          '${points.length} pts, '
          '${((r['distance'] as num) / 1000).toStringAsFixed(1)} km');

      result.add(RouteModel(
  distanceText: '${((r['distance'] as num) / 1000).toStringAsFixed(1)} km',
  durationText: '${((r['duration'] as num) / 60).toStringAsFixed(0)} min',
  points: points,
  label: i < labels.length ? labels[i] : 'Route ${i + 1}',
));
    }

    return result;
  }
}