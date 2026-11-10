
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final TransformationController _transformationController =
      TransformationController();

  String _searchQuery = '';
  String? _selectedBuilding;

  double? _imageAspectRatio;
  bool _imageError = false;

  Position? _currentPosition;
  bool _isLocating = false;
  String? _locationMessage;
  bool _locationError = false;

  final List<Map<String, dynamic>> _buildings = [
    {
      'name': 'Auditorium',
      'category': 'Events & Activities',
      'description': 'Auditorium and university event facilities.',
      'icon': Icons.event,
      'x': 0.52,
      'y': 0.38,
    },
    {
      'name': 'Faculty of Technology',
      'category': 'Faculty',
      'description': 'Faculty of Technology campus location.',
      'icon': Icons.computer,
      'x': 0.68,
      'y': 0.53,
    },
    {
      'name': 'Lecture Halls Building',
      'category': 'Academic',
      'description': 'Lecture hall facilities.',
      'icon': Icons.school,
      'x': 0.42,
      'y': 0.62,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    try {
      final data = await rootBundle.load(
        'assets/images/nsbm_campus_aerial.jpg',
      );

      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );

      final frame = await codec.getNextFrame();
      final image = frame.image;

      final ratio = image.width / image.height;

      image.dispose();
      codec.dispose();

      if (!mounted) return;

      setState(() {
        _imageAspectRatio = ratio;
        _imageError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _imageError = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationMessage = 'Getting your current location...';
      _locationError = false;
    });

    try {
      // Check whether location services are enabled.
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _locationMessage =
              'Location services are turned off. Please enable GPS.';
          _locationError = true;
          _isLocating = false;
        });
        return;
      }

      // Check location permission.
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage =
              'Location permission was denied. Please allow location access.';
          _locationError = true;
          _isLocating = false;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage =
              'Location permission is permanently denied. Open app settings to allow it.';
          _locationError = true;
          _isLocating = false;
        });
        return;
      }

      // Get the current GPS position.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _locationMessage = 'Current location found successfully.';
        _locationError = false;
        _isLocating = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _locationMessage =
            'Unable to get your location. Please try again.';
        _locationError = true;
        _isLocating = false;
      });
    }
  }

  Future<void> _openLocationSettings() async {
    await Geolocator.openAppSettings();
  }

  List<Map<String, dynamic>> get _filteredBuildings {
    if (_searchQuery.trim().isEmpty) {
      return _buildings;
    }

    return _buildings.where((building) {
      return building['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _selectBuilding(Map<String, dynamic> building) {
    setState(() {
      _selectedBuilding = building['name'] as String;
    });
  }

  void _resetMap() {
    _transformationController.value = Matrix4.identity();

    setState(() {
      _selectedBuilding = null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and Search
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Campus Map',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF071B35),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Explore NSBM Green University',
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search buildings...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF087F5B),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                icon: const Icon(Icons.close),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Map Heading
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'NSBM Campus Aerial View',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF071B35),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Reset map',
                      onPressed: _resetMap,
                      icon: const Icon(
                        Icons.zoom_out_map,
                        color: Color(0xFF087F5B),
                      ),
                    ),
                  ],
                ),
              ),

              // Aerial Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final mapWidth = constraints.maxWidth;
                      final ratio = _imageAspectRatio ?? 1.5;
                      final mapHeight = mapWidth / ratio;

                      return Container(
                        width: mapWidth,
                        height: mapHeight,
                        color: const Color(0xFFE5EAF0),
                        child: _imageError
                            ? const Center(
                                child: Text(
                                  'Campus image not found.\n'
                                  'Please check the image asset.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : _imageAspectRatio == null
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF087F5B),
                                    ),
                                  )
                                : InteractiveViewer(
                                    transformationController:
                                        _transformationController,
                                    minScale: 1,
                                    maxScale: 4,
                                    boundaryMargin:
                                        const EdgeInsets.all(40),
                                    child: SizedBox(
                                      width: mapWidth,
                                      height: mapHeight,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.asset(
                                            'assets/images/nsbm_campus_aerial.jpg',
                                            fit: BoxFit.fill,
                                          ),
                                          ..._buildings.map((building) {
                                            final isSelected =
                                                _selectedBuilding ==
                                                    building['name'];

                                            final x =
                                                building['x'] as double;
                                            final y =
                                                building['y'] as double;

                                            return Positioned(
                                              left: mapWidth * x - 65,
                                              top: mapHeight * y,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _selectBuilding(building),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                        maxWidth: 130,
                                                      ),
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6,
                                                      ),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: isSelected
                                                            ? const Color(
                                                                0xFF087F5B)
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withValues(
                                                              alpha: 0.25,
                                                            ),
                                                            blurRadius: 5,
                                                            offset:
                                                                const Offset(
                                                              0, 2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        building['name']
                                                            as String,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isSelected
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xFF071B35),
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 28,
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFF087F5B)
                                                          : Colors.red.shade700,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                      );
                    },
                  ),
                ),
              ),

              // Map Hint
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 17,
                      color: Colors.blueGrey.shade600,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Pinch to zoom and drag to explore the campus.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Current Location Section
              _buildCurrentLocationCard(),

              // Campus Destination Selection
              _buildNavigationCard(),

              // Selected Building Details
              if (_selectedBuilding != null)
                _buildSelectedBuilding(),

              // Building Directory
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 12),
                child: Text(
                  'Buildings & Locations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF071B35),
                  ),
                ),
              ),

              if (_filteredBuildings.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(25),
                  child: Center(
                    child: Text('No buildings found'),
                  ),
                )
              else
                ..._filteredBuildings.map((building) {
                  final isSelected =
                      _selectedBuilding == building['name'];

                  return Card(
                    color: isSelected
                        ? const Color(0xFFEAF4F1)
                        : Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF087F5B)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => _selectBuilding(building),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEAF4F1),
                        child: Icon(
                          building['icon'] as IconData,
                          color: const Color(0xFF087F5B),
                        ),
                      ),
                      title: Text(
                        building['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF071B35),
                        ),
                      ),
                      subtitle: Text(
                        building['category'] as String,
                      ),
                      trailing: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.arrow_forward_ios,
                        size: 17,
                        color: const Color(0xFF087F5B),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.directions_walk,
                color: Color(0xFF087F5B),
              ),
              SizedBox(width: 9),
              Text(
                'Campus Navigation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF071B35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Choose your destination',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedBuilding,
            isExpanded: true,
            hint: const Text('Select a campus building'),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF4F7FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: _buildings.map((building) {
              return DropdownMenuItem<String>(
                value: building['name'] as String,
                child: Text(building['name'] as String),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBuilding = value;
              });
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_selectedBuilding == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a destination.'),
                    ),
                  );
                  return;
                }

                if (_currentPosition == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please get your current GPS location first.',
                      ),
                    ),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Destination selected: $_selectedBuilding. '
                      'Walking route data is not configured yet.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.route),
              label: const Text('Plan Walking Route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087F5B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Walking paths and building entrances must be verified '
            'before accurate routes, distances and walking times '
            'can be displayed.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blueGrey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
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
          const SizedBox(height: 12),

          if (_currentPosition != null) ...[
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF087F5B),
                  size: 18,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Current location found successfully.',
                    style: TextStyle(
                      color: Color(0xFF087F5B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _coordinateRow(
              'Latitude',
              _currentPosition!.latitude.toStringAsFixed(6),
            ),
            const SizedBox(height: 5),
            _coordinateRow(
              'Longitude',
              _currentPosition!.longitude.toStringAsFixed(6),
            ),
            const SizedBox(height: 5),
            _coordinateRow(
              'Accuracy',
              '${_currentPosition!.accuracy.toStringAsFixed(1)} metres',
            ),
          ] else if (_locationMessage != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _locationError
                      ? Icons.error_outline
                      : Icons.info_outline,
                  color: _locationError
                      ? Colors.red.shade700
                      : Colors.blueGrey,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _locationError
                          ? Colors.red.shade700
                          : Colors.blueGrey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ] else
            Text(
              'Tap the button below to find your current GPS location.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blueGrey.shade600,
              ),
            ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLocating ? null : _getCurrentLocation,
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (_locationError &&
              _locationMessage != null &&
              _locationMessage!.contains('permanently denied')) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _openLocationSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Open App Settings'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _coordinateRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF071B35),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedBuilding() {
    final building = _buildings.firstWhere(
      (item) => item['name'] == _selectedBuilding,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF087F5B),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFEAF4F1),
            child: Icon(
              Icons.location_on,
              color: Color(0xFF087F5B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  building['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF071B35),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  building['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedBuilding = null;
              });
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
