import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Modelo de datos para conductores
class Driver {
  final String id;
  final String name;
  final String email;
  final String carInfo;
  final LatLng currentLocation;
  final LatLng destination;
  final String destinationName;
  final double rating;
  final bool isOnline;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.carInfo,
    required this.currentLocation,
    required this.destination,
    required this.destinationName,
    required this.rating,
    required this.isOnline,
  });
}

class DriverService {
  // Lista de conductores simulados en San Francisco
  static final List<Driver> mockDrivers = [
    Driver(
      id: '1',
      name: 'John Doe',
      email: 'john@triplo.com',
      carInfo: 'Tesla Model 3 - White - SF123AB',
      currentLocation: const LatLng(37.7802, -122.4064), // Financial District
      destination: const LatLng(37.7749, -122.4194), // City Hall
      destinationName: 'San Francisco City Hall',
      rating: 4.8,
      isOnline: true,
    ),
    Driver(
      id: '2',
      name: 'Alice Smith',
      email: 'alice@triplo.com',
      carInfo: 'Toyota Prius - Black - SF456CD',
      currentLocation: const LatLng(37.8019, -122.4189), // Fisherman's Wharf
      destination: const LatLng(37.7786, -122.3892), // Chase Center
      destinationName: 'Chase Center',
      rating: 4.9,
      isOnline: true,
    ),
    Driver(
      id: '3',
      name: 'Bob Wilson',
      email: 'bob@triplo.com',
      carInfo: 'Honda Civic - Silver - SF789EF',
      currentLocation: const LatLng(37.7879, -122.4074), // Union Square
      destination: const LatLng(37.8087, -122.4098), // Pier 39
      destinationName: 'Pier 39',
      rating: 4.7,
      isOnline: true,
    ),
  ];

  // Obtiene los marcadores de conductores activos para el mapa
  static Set<Marker> getDriverMarkers(Function(Driver) onTap) {
    return mockDrivers
        .where((driver) => driver.isOnline) // Filtra solo conductores en línea
        .map(
          (driver) => Marker(
            markerId: MarkerId(driver.id),
            position: driver.currentLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(
              title: driver.name,
              snippet: 'Destino: ${driver.destinationName}',
            ),
            onTap: () => onTap(driver),
          ),
        )
        .toSet();
  }

  // Muestra el diálogo con información del conductor
  static Future<void> showDriverInfo(BuildContext context, Driver driver) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(driver.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vehículo: ${driver.carInfo}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${driver.rating}'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ruta actual:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Desde: ${_getLocationName(driver.currentLocation)}'),
                Text('Hasta: ${driver.destinationName}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Solicitar Viaje'),
              ),
            ],
          ),
    );
  }

  // Convierte coordenadas a nombres de ubicaciones conocidas
  static String _getLocationName(LatLng location) {
    const locations = {
      '37.7802,-122.4064': 'Financial District',
      '37.8019,-122.4189': "Fisherman's Wharf",
      '37.7879,-122.4074': 'Union Square',
    };
    return locations['${location.latitude},${location.longitude}'] ??
        'Ubicación desconocida';
  }
}
