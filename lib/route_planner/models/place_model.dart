import 'package:latlong2/latlong.dart';

class PlaceModel {
  final String shortName;
  final String displayName;
  final LatLng location;

  PlaceModel({
    required this.shortName,
    required this.displayName,
    required this.location,
  });

  factory PlaceModel.fromNominatim(Map<String, dynamic> json) {
    final lat = double.parse(json['lat'].toString());
    final lon = double.parse(json['lon'].toString());

    return PlaceModel(
      shortName: json['display_name'] ?? '',
      displayName: json['display_name'] ?? '',
      location: LatLng(lat, lon),
    );
  }
}