
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  final MapController _mapController = MapController();

  // Approximate NSBM campus centre.
  static const LatLng _campusCenter = LatLng(
    6.8209,
    80.0397,
  );

  Position? _currentPosition;
  bool _isLocating = false;

  String? _locationMessage;
  bool _locationError = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationMessage = 'Getting your current location...';
      _locationError = false;
    });

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Please enable GPS on your device.');
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is permanently denied. '
          'Please enable it in app settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _locationMessage = 'Your location was found.';
        _locationError = false;
        _isLocating = false;
      });

      _mapController.move(
        LatLng(position.latitude, position.longitude),
        18,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _locationMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        _locationError = true;
        _isLocating = false;
      });
    }
  }

  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  void _resetMap() {
    _mapController.move(_campusCenter, 16);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20, 18, 20, 12,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campus Map',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF071B35),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Explore NSBM Green University',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _resetMap,
                    tooltip: 'Reset map',
                    icon: const Icon(
                      Icons.zoom_out_map,
                      color: Color(0xFF087F5B),
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Map
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: _campusCenter,
                      initialZoom: 16,
                      minZoom: 3,
                      maxZoom: 19,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/'
                            '{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.ishen.nsbm_smart_campus',
                        maxZoom: 19,
                      ),

                      // Map markers
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _campusCenter,
                            width: 120,
                            height: 65,
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 38,
                                  color: Color(0xFF087F5B),
                                ),
                                Text(
                                  'NSBM Campus',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF071B35),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (_currentPosition != null)
                            Marker(
                              point: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              width: 45,
                              height: 45,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.my_location,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // OpenStreetMap attribution
                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Map controls
                  Positioned(
                    right: 14,
                    top: 14,
                    child: Column(
                      children: [
                        _mapButton(
                          icon: Icons.add,
                          onPressed: () {
                            final camera =
                                _mapController.camera;
                            _mapController.move(
                              camera.center,
                              camera.zoom + 1,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _mapButton(
                          icon: Icons.remove,
                          onPressed: () {
                            final camera =
                                _mapController.camera;
                            _mapController.move(
                              camera.center,
                              camera.zoom - 1,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _mapButton(
                          icon: Icons.my_location,
                          onPressed: _getCurrentLocation,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Current location information
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE1E8EF),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Color(0xFF087F5B),
                      ),
                      SizedBox(width: 9),
                      Text(
                        'My Current Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF071B35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_currentPosition != null)
                    Text(
                      'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}\n'
                      'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    )
                  else
                    Text(
                      _locationMessage ??
                          'Find your current location using GPS.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _locationError
                            ? Colors.red
                            : Colors.blueGrey,
                      ),
                    ),

                  if (_locationError &&
                      (_locationMessage?.contains(
                            'permanently denied',
                          ) ??
                          false))
                    TextButton(
                      onPressed: _openAppSettings,
                      child: const Text('Open App Settings'),
                    ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLocating
                          ? null
                          : _getCurrentLocation,
                      icon: _isLocating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        _isLocating
                            ? 'Getting Location...'
                            : 'My Location',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF087F5B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(10),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: const Color(0xFF071B35),
        ),
      ),
    );
  }
}
