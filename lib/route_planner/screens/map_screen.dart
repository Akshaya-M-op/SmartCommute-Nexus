import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/place_model.dart';
import '../models/route_model.dart';
import '../services/directions_service.dart';
import '../services/geocoding_service.dart';
import '../services/feedback_service.dart';
import '../screens/feedback_screen.dart';
import 'package:smartcommute/safety_layer.dart';
// ─── Colour palette ──────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF1A73E8); // Google-blue
const _kAlt = Color(0xFF34A853); // green for alternative routes
const _kSurface = Colors.white;

class MapScreen extends StatefulWidget {
  final String language;
  final bool accessibilityMode;

  const MapScreen({
    super.key,
    required this.language,
    required this.accessibilityMode,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

 class _MapScreenState extends State<MapScreen> {

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

  // ── Services ──────────────────────────────────────────────────────────────
  final _directions = DirectionsService();
  final _geocoding = GeocodingService();
  final _mapController = MapController();

  // ── Text controllers ──────────────────────────────────────────────────────
  final _srcCtrl = TextEditingController();
  final _dstCtrl = TextEditingController();
  final _srcFocus = FocusNode();
  final _dstFocus = FocusNode();

  // ── State ─────────────────────────────────────────────────────────────────
  PlaceModel? _origin;
  PlaceModel? _destination;

  List<PlaceModel> _suggestions = [];
  bool _showSuggestions = false;
  bool _searchingForOrigin = true; // true = filling origin, false = destination

  List<RouteModel> _routes = [];
  int _selectedRouteIndex = 0;

  bool _loadingRoute = false;
  bool _loadingLocation = false;
  String? _errorMessage;

  Timer? _debounce;
  final FeedbackService _feedbackService = FeedbackService();

  // ── Init / Dispose ────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _srcFocus.addListener(() {
      if (_srcFocus.hasFocus) _searchingForOrigin = true;
    });
    _dstFocus.addListener(() {
      if (_dstFocus.hasFocus) _searchingForOrigin = false;
    });
  }

  @override
  void dispose() {
    _srcCtrl.dispose();
    _dstCtrl.dispose();
    _srcFocus.dispose();
    _dstFocus.dispose();
    _debounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // ── Search / Geocoding ────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _geocoding.searchPlaces(query);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _showSuggestions = results.isNotEmpty;
      });
    });
  }

  void _selectSuggestion(PlaceModel place) {
    setState(() {
      if (_searchingForOrigin) {
        _origin = place;
        _srcCtrl.text = place.shortName;
      } else {
        _destination = place;
        _dstCtrl.text = place.shortName;
      }
      _suggestions = [];
      _showSuggestions = false;
    });
    FocusScope.of(context).unfocus();
    if (_origin != null && _destination != null) _fetchRoutes();
  }

  // ── Live location ─────────────────────────────────────────────────────────
  Future<void> _useMyLocation() async {
    setState(() => _loadingLocation = true);
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('Location services are disabled.');

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final name = await _geocoding.reverseGeocode(pos.latitude, pos.longitude);
      final place = PlaceModel(
        shortName: name,
        displayName: name,
        location: LatLng(pos.latitude, pos.longitude),
      );

      if (!mounted) return;
      setState(() {
        _origin = place;
        _srcCtrl.text = place.shortName;
        _loadingLocation = false;
      });
      _mapController.move(
  place.location,
  15,
);

      if (_destination != null) _fetchRoutes();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingLocation = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ── Route fetching ────────────────────────────────────────────────────────
  Future<void> _fetchRoutes() async {
  if (_origin == null || _destination == null) return;

  FocusScope.of(context).unfocus();

  setState(() {
    _loadingRoute = true;
    _errorMessage = null;
    _routes = [];
    _selectedRouteIndex = 0;
  });

  try {
    final routes = await _directions.getRoutes(
      _origin!.location.latitude,
      _origin!.location.longitude,
      _destination!.location.latitude,
      _destination!.location.longitude,
    );

    if (!mounted) return;

    setState(() {
      _routes = routes;
      _loadingRoute = false;
    });

    if (_routes.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        _fitBounds();
      });
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _loadingRoute = false;
      _errorMessage =
          'Could not find a route. Please try different locations.';
    });
  }
}

  void _fitBounds() {
    if (_routes.isEmpty || _routes[_selectedRouteIndex].points.isEmpty) return;
    final pts = _routes[_selectedRouteIndex].points;
    final bounds = LatLngBounds.fromPoints(pts);

    // Small post-frame delay so the controller is settled after setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(40, 140, 40, 180),
          maxZoom: 16, // never zoom in past street level
        ),
      );
    });
  }

  void _swapLocations() {
    final tmpOrigin = _origin;
    final tmpDest = _destination;
    setState(() {
      _origin = tmpDest;
      _destination = tmpOrigin;
      _srcCtrl.text = _origin?.shortName ?? '';
      _dstCtrl.text = _destination?.shortName ?? '';
      // Don't clear routes here — keep showing old route while new one loads
      _selectedRouteIndex = 0;
    });
    if (_origin != null && _destination != null) _fetchRoutes();
  }

  void _clearAll() {
    setState(() {
      _origin = null;
      _destination = null;
      _srcCtrl.clear();
      _dstCtrl.clear();
      _routes = [];
      _suggestions = [];
      _showSuggestions = false;
      _errorMessage = null;
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _routeColor(int index) =>
      index == _selectedRouteIndex ? _kPrimary : _kAlt.withAlpha(180);

  double _routeWidth(int index) =>
      index == _selectedRouteIndex ? 5 : 3;

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: false,

    // ───────── BODY ─────────
    body: Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(20.5937, 78.9629),
            initialZoom: 5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.smart_route_planner',
            ),

            if (_routes.isNotEmpty)
              PolylineLayer(
                polylines: [
                  for (int i = _routes.length - 1; i >= 0; i--)
                    if (_routes[i].points.length > 1)
                      Polyline(
                        points: _routes[i].points,
                        strokeWidth: _routeWidth(i),
                        color: _routeColor(i),
                      ),
                ],
              ),

            if (_origin != null || _destination != null)
              MarkerLayer(
                markers: [
                  if (_origin != null)
                    _buildMarker(
                      _origin!.location,
                      Icons.trip_origin,
                      _kPrimary,
                    ),
                  if (_destination != null)
                    _buildMarker(
                      _destination!.location,
                      Icons.location_pin,
                      Colors.red,
                      size: 40,
                    ),
                ],
              ),
          ],
        ),

        // ── SEARCH PANEL ──
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Column(
              children: [
                _SearchPanel(
                  language: widget.language,
                  t: t,
                  srcCtrl: _srcCtrl,
                  dstCtrl: _dstCtrl,
                  srcFocus: _srcFocus,
                  dstFocus: _dstFocus,
                  loadingLocation: _loadingLocation,
                  onSrcChanged: (v) {
                    _searchingForOrigin = true;
                    _onSearchChanged(v);
                  },
                  onDstChanged: (v) {
                    _searchingForOrigin = false;
                    _onSearchChanged(v);
                  },
                  onMyLocation: _useMyLocation,
                  onSwap: _swapLocations,
                  onClear: _clearAll,
                  onSearch: (_origin != null && _destination != null)
                      ? _fetchRoutes
                      : null,
                ),

                if (_showSuggestions)
                  _SuggestionsDropdown(
                    suggestions: _suggestions,
                    onSelect: _selectSuggestion,
                  ),
              ],
            ),
          ),
        ),

        // ── LOADING ──
        if (_loadingRoute)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x55000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

        // ── ERROR ──
        if (_errorMessage != null)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.red,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),

        // ── ROUTE CARD ──
        if (_routes.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _RouteInfoCard(
              routes: _routes,
              selectedIndex: _selectedRouteIndex,
              onSelectRoute: (i) {
                setState(() => _selectedRouteIndex = i);
                _fitBounds();
              },
            ),
          ),

        // ── FEEDBACK FAB ──
        Positioned(
          bottom: 120,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: _kPrimary,
            child: const Icon(Icons.feedback, color: Colors.white),
            onPressed: () {
               Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FeedbackScreen(),
    ),
  );
            },
          ),
        ),
      ],
    ),

    // ───────── SAFETY BUTTON (CORRECT PLACE) ─────────
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: _kPrimary,
      icon: const Icon(Icons.security),
      label: const Text("Safety"),
      onPressed: () {
        if (_routes.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a route first")),
          );
          return;
        }

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return SafetyLayer(
              language: widget.language,
              accessibilityMode: widget.accessibilityMode,
              routeA: _routes.isNotEmpty ? _routes[0] : null,
              routeB: _routes.length > 1 ? _routes[1] : null,
            );
          },
        );
      },
    ),
  );
}

  }

  Marker _buildMarker(
    LatLng point,
    IconData icon,
    Color color, {
    double size = 36,
  }) {
    return Marker(
      point: point,
      width: size,
      height: size,
      child: Icon(icon, color: color, size: size),
    );
  }

// ─── Search Panel ─────────────────────────────────────────────────────────────
class _SearchPanel extends StatelessWidget {
  final String language;
  final String Function(String, String, String, String) t;
  const _SearchPanel({
    required this.language,
    required this.t,
    required this.srcCtrl,
    required this.dstCtrl,
    required this.srcFocus,
    required this.dstFocus,
    required this.loadingLocation,
    required this.onSrcChanged,
    required this.onDstChanged,
    required this.onMyLocation,
    required this.onSwap,
    required this.onClear,
    this.onSearch,
  });

  final TextEditingController srcCtrl;
  final TextEditingController dstCtrl;
  final FocusNode srcFocus;
  final FocusNode dstFocus;
  final bool loadingLocation;
  final ValueChanged<String> onSrcChanged;
  final ValueChanged<String> onDstChanged;
  final VoidCallback onMyLocation;
  final VoidCallback onSwap;
  final VoidCallback onClear;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 12, color: Colors.black26, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App bar row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.route, color: _kPrimary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t(
  language,
  "Smart Route Planner",
  "ஸ்மார்ட் ரூட் பிளானர்",
  "स्मार्ट रूट प्लानर",
),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF202124)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all, size: 22),
                  tooltip: 'Clear',
                  onPressed: onClear,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Origin row
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Icon(Icons.trip_origin, size: 16, color: _kPrimary),
                    Container(
                        width: 1, height: 20, color: Colors.grey.shade300),
                    Icon(Icons.location_pin, size: 16, color: Colors.red),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: srcCtrl,
                      focusNode: srcFocus,
                      onChanged: onSrcChanged,
                      decoration: InputDecoration(
                        hintText: 'Choose starting point',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: loadingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.my_location,
                                    size: 18, color: _kPrimary),
                                tooltip: 'Use my location',
                                onPressed: onMyLocation,
                              ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    TextField(
                      controller: dstCtrl,
                      focusNode: dstFocus,
                      onChanged: onDstChanged,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => onSearch?.call(),
                      decoration: InputDecoration(
                        hintText: 'Choose destination',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: onSearch != null
                            ? IconButton(
                                icon: const Icon(Icons.search,
                                    size: 18, color: _kPrimary),
                                tooltip: 'Get route',
                                onPressed: onSearch,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.swap_vert, color: _kPrimary),
                tooltip: 'Swap',
                onPressed: onSwap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Suggestions Dropdown ─────────────────────────────────────────────────────
class _SuggestionsDropdown extends StatelessWidget {
  const _SuggestionsDropdown({
    required this.suggestions,
    required this.onSelect,
  });

  final List<PlaceModel> suggestions;
  final ValueChanged<PlaceModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 4))
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (_, i) {
          final p = suggestions[i];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.place_outlined,
                size: 18, color: Colors.grey),
            title: Text(p.shortName,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              p.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
            onTap: () => onSelect(p),
          );
        },
      ),
    );
  }
}

// ─── Route Info Card ──────────────────────────────────────────────────────────
class _RouteInfoCard extends StatelessWidget {
  const _RouteInfoCard({
    required this.routes,
    required this.selectedIndex,
    required this.onSelectRoute,
  });

  final List<RouteModel> routes;
  final int selectedIndex;
  final ValueChanged<int> onSelectRoute;

  @override
  Widget build(BuildContext context) {
    final selected = routes.isNotEmpty
    ? routes[selectedIndex.clamp(0, routes.length - 1)]
    : null;
    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(blurRadius: 16, color: Colors.black26, offset: Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Main info
          Padding(
  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
  child: Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
  selected == null
      ? "No route selected"
      : selected.durationText,
  style: const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Color(0xFF202124),
  ),
),
          Text(
            selected?.distanceText ?? "",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),

      const Spacer(),

      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _kPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          selected?.label ?? "Route",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    ],
  ),
),// Alternative routes
          if (routes.length > 1) ...[
            Divider(color: Colors.grey.shade200, height: 1),
            SizedBox(
              height: 68,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                itemCount: routes.length,
                itemBuilder: (_, i) {
                  final r = routes[i];
                  final isSelected = i == selectedIndex;
                  return GestureDetector(
                    onTap: () => onSelectRoute(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _kPrimary
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected ? _kPrimary : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            r.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${r.durationText}  ·  ${r.distanceText}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}