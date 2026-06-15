import 'package:latlong2/latlong.dart';

class RouteModel {
  final String label;
  final String durationText;
  final String distanceText;
  final List<LatLng> points;

  RouteModel({
    required this.label,
    required this.durationText,
    required this.distanceText,
    required this.points,
  });
}