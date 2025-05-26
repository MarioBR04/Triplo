import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_maps_webservice/places.dart' as maps_webservice;
import '../core/constants.dart';
import '../core/config.dart';
import 'dart:async';

// Página para el modo conductor
class DriverModePage extends StatefulWidget {
  const DriverModePage({Key? key}) : super(key: key);

  @override
  State<DriverModePage> createState() => _DriverModePageState();
}

class _DriverModePageState extends State<DriverModePage> {
  final TextEditingController _destinationController = TextEditingController();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isOnline = false;
  bool _isLoading = true;
  String? _errorMessage;
  LatLng? _destinationLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isTripStarted = false;

  // Nuevos estados para la lógica de solicitud y recogida
  bool _showAcceptRequestButton = false;
  bool _hasAcceptedRequest = false;
  LatLng? _pickupLocation;
  Timer? _acceptRequestTimer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _acceptRequestTimer?.cancel();
    super.dispose();
  }

  // Obtiene la ubicación actual del conductor
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _updateMarkers();
      });
      _moveCamera();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al obtener la ubicación';
      });
    }
  }

  // Actualiza los marcadores en el mapa (ubicación actual, destino y recogida)
  void _updateMarkers() {
    final markers = <Marker>{
      if (_currentPosition != null)
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Mi ubicación'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      if (_destinationLocation != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: _destinationLocation!,
          infoWindow: const InfoWindow(title: 'Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      if (_pickupLocation != null)
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickupLocation!,
          infoWindow: const InfoWindow(title: 'Punto de recogida'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
    };

    setState(() {
      _markers = markers;
    });
  }

  // Centra el mapa en la ubicación actual
  void _moveCamera() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 13,
          ),
        ),
      );
    }
  }

  // Maneja la selección del destino del conductor
  void _onDestinationSelected(Prediction prediction) async {
    final places = maps_webservice.GoogleMapsPlaces(
      apiKey: Config.googleMapsApiKey,
    );
    final detail = await places.getDetailsByPlaceId(prediction.placeId!);

    if (detail.result.geometry?.location != null) {
      setState(() {
        _destinationLocation = LatLng(
          detail.result.geometry!.location.lat,
          detail.result.geometry!.location.lng,
        );
        _destinationController.text = prediction.description!;
        _updateMarkers();
      });

      // Ajusta el zoom para mostrar tanto la ubicación actual como el destino
      if (_mapController != null && _currentPosition != null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            _currentPosition!.latitude < _destinationLocation!.latitude
                ? _currentPosition!.latitude
                : _destinationLocation!.latitude,
            _currentPosition!.longitude < _destinationLocation!.longitude
                ? _currentPosition!.longitude
                : _destinationLocation!.longitude,
          ),
          northeast: LatLng(
            _currentPosition!.latitude > _destinationLocation!.latitude
                ? _currentPosition!.latitude
                : _destinationLocation!.latitude,
            _currentPosition!.longitude > _destinationLocation!.longitude
                ? _currentPosition!.longitude
                : _destinationLocation!.longitude,
          ),
        );

        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    }
  }

  // Inicia el viaje del conductor
  void _startTrip() {
    setState(() {
      _isTripStarted = true;
      _hasAcceptedRequest = false;
      _pickupLocation = null;
      _showAcceptRequestButton = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.blue, size: 32),
                SizedBox(width: 12),
                Text(
                  'Viaje Iniciado',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
    );

    // Quita el popup después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });

    // Después de 5 segundos de iniciar el viaje, muestra el botón para aceptar solicitud
    _acceptRequestTimer?.cancel();
    _acceptRequestTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isTripStarted && !_hasAcceptedRequest) {
        setState(() {
          _showAcceptRequestButton = true;
        });
      }
    });
  }

  // Simula aceptar una solicitud de pasajero cercano
  void _acceptNearbyRequest() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Text('Nueva Solicitud'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del pasajero
                const Text(
                  'Información del Pasajero',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.deepBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 20,
                      color: AppColors.darkBlueGray,
                    ),
                    SizedBox(width: 8),
                    Text('María García'),
                  ],
                ),
                const Row(
                  children: [
                    Icon(Icons.star, size: 20, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('4.8'),
                  ],
                ),
                const SizedBox(height: 16),

                // Detalles del viaje
                const Text(
                  'Detalles del Viaje',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.deepBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 20,
                      color: AppColors.darkBlueGray,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Punto de Recogida:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            _getLocationName(_currentPosition!),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.flag,
                      size: 20,
                      color: AppColors.darkBlueGray,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destino del Pasajero:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Chase Center, San Francisco',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Distancia', style: TextStyle(fontSize: 12)),
                          Text(
                            '2.5 km',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Tiempo Est.', style: TextStyle(fontSize: 12)),
                          Text(
                            '10 min',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text('Tarifa', style: TextStyle(fontSize: 12)),
                          Text(
                            '\$12.50',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Rechazar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Simulamos un punto de recogida cercano
                  if (_currentPosition != null) {
                    final pickup = LatLng(
                      _currentPosition!.latitude + 0.001,
                      _currentPosition!.longitude + 0.001,
                    );
                    setState(() {
                      _pickupLocation = pickup;
                      _hasAcceptedRequest = true;
                      _showAcceptRequestButton = false;
                    });
                    _updateMarkers();

                    // Centrar el mapa para mostrar el punto de recogida
                    if (_mapController != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(pickup, 15),
                      );
                    }

                    // Mostrar mensaje de confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Has aceptado la solicitud de viaje'),
                        backgroundColor: AppColors.blue,
                      ),
                    );
                  }
                },
                child: const Text('Aceptar Viaje'),
              ),
            ],
          ),
    );
  }

  // Obtiene el nombre de la ubicación basado en coordenadas
  String _getLocationName(Position position) {
    // Simulación de nombres de ubicaciones
    const locations = {
      '37.7749,-122.4194': 'Financial District, San Francisco',
      '37.7899,-122.4000': 'Union Square, San Francisco',
      '37.8019,-122.4189': "Fisherman's Wharf, San Francisco",
    };

    return locations['${position.latitude.toStringAsFixed(4)},${position.longitude.toStringAsFixed(4)}'] ??
        'San Francisco Downtown';
  }

  // Termina el viaje
  void _endTrip() {
    setState(() {
      _isTripStarted = false;
      _hasAcceptedRequest = false;
      _pickupLocation = null;
      _showAcceptRequestButton = false;
    });
    _updateMarkers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Viaje terminado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Muestra pantalla de carga
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Muestra pantalla de error
    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text(_errorMessage!)));
    }

    // Construye la interfaz principal
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlueGray),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Modo Conductor',
          style: TextStyle(
            color: AppColors.darkBlueGray,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Switch para activar/desactivar modo conductor
          Switch(
            value: _isOnline,
            onChanged: (value) {
              setState(() {
                _isOnline = value;
              });
            },
            activeColor: AppColors.blue,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Mapa de Google
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                _currentPosition?.latitude ?? 37.7749,
                _currentPosition?.longitude ?? -122.4194,
              ),
              zoom: 13,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _updateMarkers();
            },
          ),
          // Panel de búsqueda y controles
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Campo de búsqueda de destino
                    GooglePlaceAutoCompleteTextField(
                      textEditingController: _destinationController,
                      googleAPIKey: Config.googleMapsApiKey,
                      inputDecoration: InputDecoration(
                        hintText: '¿A dónde vas?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      debounceTime: 800,
                      countries: const ['us'],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) {
                        _onDestinationSelected(prediction);
                      },
                      itemClick: (Prediction prediction) {
                        _onDestinationSelected(prediction);
                      },
                    ),
                    const SizedBox(height: 8),
                    // Mensaje de estado y botón de inicio
                    if (_isOnline &&
                        _destinationLocation != null &&
                        !_isTripStarted)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Tu ubicación es visible para los pasajeros',
                          style: TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (_isOnline &&
                        _destinationLocation != null &&
                        !_isTripStarted)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Iniciar Viaje'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onPressed:
                                _isTripStarted
                                    ? null
                                    : () {
                                      _startTrip();
                                    },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Botón para aceptar solicitud de pasajero cercano (aparece 5s después de iniciar viaje)
          if (_isTripStarted &&
              _showAcceptRequestButton &&
              !_hasAcceptedRequest)
            Positioned(
              bottom: 100,
              left: 32,
              right: 32,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_pin_circle),
                label: const Text('Aceptar solicitud de pasajero cercano'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: _acceptNearbyRequest,
              ),
            ),
          // Botón para terminar viaje (aparece en cuanto se inicia el viaje)
          if (_isTripStarted)
            Positioned(
              bottom: 32,
              left: 32,
              right: 32,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.stop_circle),
                label: const Text('Terminar Viaje'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: _endTrip,
              ),
            ),
        ],
      ),
    );
  }
}
