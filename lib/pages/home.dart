import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_maps_webservice/places.dart' as maps_webservice;
import 'package:google_maps_webservice/directions.dart' as maps_directions;
import '../core/constants.dart';
import '../core/config.dart';
import '../services/loginService.dart';
import '../widgets/sidebar.dart';

class HomePage extends StatefulWidget {
  final LoginService? loginService;

  const HomePage({Key? key, this.loginService}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final LoginService _loginService;
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};
  final places = maps_webservice.GoogleMapsPlaces(
    apiKey: Config.googleMapsApiKey,
  );
  final directions = maps_directions.GoogleMapsDirections(
    apiKey: Config.googleMapsApiKey,
  );

  @override
  void initState() {
    super.initState();
    _loginService = widget.loginService ?? LoginService();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLoading = false;
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  Future<void> _onPlaceSelected(Prediction prediction) async {
    final details = await places.getDetailsByPlaceId(prediction.placeId!);
    if (details.result.geometry?.location != null) {
      final location = details.result.geometry!.location;
      final latLng = LatLng(location.lat, location.lng);

      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('selected_place'),
            position: latLng,
            infoWindow: InfoWindow(title: prediction.description),
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 15),
        ),
      );

      _destinationController.text = prediction.description ?? '';
    }
  }

  Future<String> _calculateDistance(LatLng destination) async {
    try {
      final result = await directions.directionsWithLocation(
        maps_directions.Location(
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
        ),
        maps_directions.Location(
          lat: destination.latitude,
          lng: destination.longitude,
        ),
        travelMode: maps_directions.TravelMode.driving,
      );

      if (result.isOkay && result.routes.isNotEmpty) {
        final route = result.routes.first;
        final leg = route.legs.first;
        return leg.distance.text;
      }
      return '-- km';
    } catch (e) {
      print('Error calculating distance: $e');
      return '-- km';
    }
  }

  void _findDriver() async {
    setState(() {
      _errorMessage = null;
    });

    if (_destinationController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a destination';
      });
      return;
    }

    if (_passengersController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter number of passengers';
      });
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
          ),
        );
      },
    );

    // Get distance
    String distance = '-- km';
    if (_markers.isNotEmpty) {
      final destination = _markers.first.position;
      distance = await _calculateDistance(destination);
    }

    // Simulate driver search delay
    await Future.delayed(const Duration(seconds: 4));

    // Close loading dialog
    Navigator.of(context).pop();

    // Show driver found dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(width: 10),
              const Text('¡Driver Found!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daniel can take you to ${_destinationController.text}!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Pickup in 12 minutes', style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.route, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Distance: $distance',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.attach_money, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Fare: \$42', style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí podrías navegar a una pantalla de detalles del viaje
              },
              child: const Text('Accept Ride'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                key: const Key('menu_button'),
                icon: const Icon(Icons.menu, color: AppColors.darkBlueGray),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: const Text(
          'triplo',
          style: TextStyle(
            color: AppColors.darkBlueGray,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Sidebar(loginService: _loginService),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_currentPosition != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Where you going?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GooglePlaceAutoCompleteTextField(
                      textEditingController: _destinationController,
                      googleAPIKey: Config.googleMapsApiKey,
                      inputDecoration: const InputDecoration(
                        hintText: 'Enter destination',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      debounceTime: 800,
                      countries: const ["mx"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) {
                        _onPlaceSelected(prediction);
                      },
                      itemClick: (Prediction prediction) {
                        _onPlaceSelected(prediction);
                      },
                      seperatedBuilder: const Divider(),
                      // optional
                      itemBuilder: (context, index, Prediction prediction) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(prediction.description ?? ""),
                              ),
                            ],
                          ),
                        );
                      },
                      isCrossBtnShown: true,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'How many are you?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('passenger_count_field'),
                      controller: _passengersController,
                      decoration: const InputDecoration(
                        hintText: 'Number of passengers',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _findDriver,
        label: const Text('Find Driver'),
        icon: const Icon(Icons.local_taxi),
      ),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _passengersController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
