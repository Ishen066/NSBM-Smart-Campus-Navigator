
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class CampusPlace {
  final String name;
  final String category;
  final LatLng location;
  final IconData icon;

  const CampusPlace({
    required this.name,
    required this.category,
    required this.location,
    required this.icon,
  });
}

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController =
      TextEditingController();

  static const LatLng _campusCenter =
      LatLng(6.82092, 80.03966);

  static const List<CampusPlace> _places = [
    CampusPlace(
      name: 'Auditorium',
      category: 'Convention Centre',
      location: LatLng(6.82243, 80.04230),
      icon: Icons.mic,
    ),
    CampusPlace(
      name: 'Faculty of Technology',
      category: 'Faculty',
      location: LatLng(6.82210, 80.04255),
      icon: Icons.computer,
    ),
    CampusPlace(
      name: 'Academic Building',
      category: 'University Building',
      location: LatLng(6.82209, 80.04254),
      icon: Icons.school,
    ),
    CampusPlace(
      name: 'Lecture Halls Building',
      category: 'Lecture Halls',
      location: LatLng(6.82173, 80.04268),
      icon: Icons.meeting_room,
    ),
  ];

  Position? _currentPosition;
  CampusPlace? _selectedPlace;

  bool _isLocating = false;
  bool _showSearchResults = false;

  String? _locationMessage;
  bool _locationError = false;

  List<CampusPlace> get _filteredPlaces {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) return _places;

    return _places.where((place) {
      return place.name.toLowerCase().contains(query) ||
          place.category.toLowerCase().contains(query);
    }).toList();
  }

  void _selectPlace(CampusPlace place) {
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedPlace = place;
      _showSearchResults = false;
      _searchController.text = place.name;
    });

    _mapController.move(place.location, 18);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _selectedPlace = null;
      _showSearchResults = false;
    });

    FocusScope.of(context).unfocus();
    _mapController.move(_campusCenter, 16);
  }

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
          'Location permission is permanently denied.',
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

  void _resetMap() {
    setState(() {
      _selectedPlace = null;
      _searchController.clear();
      _showSearchResults = false;
    });

    _mapController.move(_campusCenter, 16);
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Column(
          children: [
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
                          'Campus Navigation',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF071B35),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Find your destination at NSBM',
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

                      MarkerLayer(
                        markers: [
                          ..._places.map((place) {
                            final isSelected =
                                _selectedPlace?.name == place.name;

                            return Marker(
                              point: place.location,
                              width: 125,
                              height: 75,
                              child: GestureDetector(
                                onTap: () => _selectPlace(place),
                                child: Column(
                                  children: [
                                    Icon(
                                      place.icon,
                                      size: 31,
                                      color: isSelected
                                          ? Colors.orange
                                          : const Color(0xFF087F5B),
                                    ),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        place.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF071B35),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          if (_currentPosition != null)
                            Marker(
                              point: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              width: 45,
                              height: 45,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 32,
                              ),
                            ),
                        ],
                      ),

                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'OpenStreetMap contributors',
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Destination search
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 65,
                    child: Column(
                      children: [
                        Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) {
                              setState(() {
                                _selectedPlace = null;
                                _showSearchResults = true;
                              });
                            },
                            onTap: () {
                              setState(() {
                                _showSearchResults = true;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search campus buildings...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF087F5B),
                              ),
                              suffixIcon: IconButton(
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.close),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),

                        if (_showSearchResults &&
                            _searchController.text.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: _filteredPlaces.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: Text(
                                      'No buildings found.',
                                    ),
                                  )
                                : Column(
                                    children: _filteredPlaces.map(
                                      (place) {
                                        return ListTile(
                                          dense: true,
                                          leading: Icon(
                                            place.icon,
                                            color: const Color(
                                              0xFF087F5B,
                                            ),
                                          ),
                                          title: Text(place.name),
                                          subtitle: Text(
                                            place.category,
                                          ),
                                          onTap: () =>
                                              _selectPlace(place),
                                        );
                                      },
                                    ).toList(),
                                  ),
                          ),
                      ],
                    ),
                  ),

                  // Map controls
                  Positioned(
                    right: 12,
                    top: 85,
                    child: Column(
                      children: [
                        _mapButton(
                          icon: Icons.add,
                          onPressed: () {
                            final camera = _mapController.camera;
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
                            final camera = _mapController.camera;
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

                  // Selected destination card
                  if (_selectedPlace != null)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFE5F4EE),
                              child: Icon(
                                Icons.location_on,
                                color: Color(0xFF087F5B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedPlace!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    _selectedPlace!.category,
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Selected',
                              style: TextStyle(
                                color: Color(0xFF087F5B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

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
                  Text(
                    _currentPosition != null
                        ? 'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}\n'
                          'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}'
                        : _locationMessage ??
                            'Use GPS to find your current location.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _locationError
                          ? Colors.red
                          : Colors.blueGrey,
                    ),
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
                        backgroundColor: const Color(0xFF087F5B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
