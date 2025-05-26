import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';

class ScheduleTripPage extends StatefulWidget {
  const ScheduleTripPage({Key? key}) : super(key: key);

  @override
  State<ScheduleTripPage> createState() => _ScheduleTripPageState();
}

class _ScheduleTripPageState extends State<ScheduleTripPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programar Viaje')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _pickupController,
              decoration: const InputDecoration(
                labelText: 'Punto de partida',
                prefixIcon: Icon(Icons.location_on, color: AppColors.blue),
                labelStyle: TextStyle(color: AppColors.darkBlueGray),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destino',
                prefixIcon: Icon(Icons.location_on, color: AppColors.blue),
                labelStyle: TextStyle(color: AppColors.darkBlueGray),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: AppColors.blue),
              title: const Text(
                'Fecha',
                style: TextStyle(color: AppColors.deepBlue),
              ),
              subtitle: Text(
                DateFormat('dd/MM/yyyy').format(selectedDate),
                style: const TextStyle(color: AppColors.darkBlueGray),
              ),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: AppColors.blue),
              title: const Text(
                'Hora',
                style: TextStyle(color: AppColors.deepBlue),
              ),
              subtitle: Text(
                selectedTime.format(context),
                style: const TextStyle(color: AppColors.darkBlueGray),
              ),
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar lógica para programar viaje
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Viaje programado exitosamente'),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.blue),
                foregroundColor: MaterialStateProperty.all(AppColors.white),
                padding: MaterialStateProperty.all(const EdgeInsets.all(16.0)),
              ),
              child: const Text('Programar Viaje'),
            ),
          ],
        ),
      ),
    );
  }
}
