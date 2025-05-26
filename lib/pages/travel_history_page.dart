import 'package:flutter/material.dart';
import '../core/constants.dart';

class TravelHistoryPage extends StatelessWidget {
  const TravelHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lista de ejemplo - Reemplazar con datos reales de Firebase
    final List<Map<String, dynamic>> trips = [
      {
        'date': '15/03/2025',
        'from': 'Casa',
        'to': 'Trabajo',
        'price': '\$150',
        'status': 'Completado',
      },
      {
        'date': '14/03/2025',
        'from': 'Trabajo',
        'to': 'Casa',
        'price': '\$145',
        'status': 'Completado',
      },
      // Agregar más viajes aquí
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Viajes')),
      body: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                '${trip['from']} → ${trip['to']}',
                style: const TextStyle(
                  color: AppColors.deepBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha: ${trip['date']}',
                    style: const TextStyle(color: AppColors.darkBlueGray),
                  ),
                  Text(
                    'Precio: ${trip['price']}',
                    style: const TextStyle(color: AppColors.darkBlueGray),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trip['status'],
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                // TODO: Mostrar detalles del viaje
              },
            ),
          );
        },
      ),
    );
  }
}
