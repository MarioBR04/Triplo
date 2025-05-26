import 'package:flutter/material.dart';
import '../core/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Usuario Ejemplo');
  final _emailController = TextEditingController(text: 'usuario@ejemplo.com');
  final _phoneController = TextEditingController(text: '123456789');
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                if (_formKey.currentState!.validate()) {
                  // TODO: Guardar cambios en Firebase
                  setState(() => _isEditing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil actualizado')),
                  );
                }
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.blue,
                child: Icon(Icons.person, size: 50, color: AppColors.white),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.blue),
                  labelStyle: TextStyle(color: AppColors.darkBlueGray),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.blue),
                  labelStyle: TextStyle(color: AppColors.darkBlueGray),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.blue),
                  labelStyle: TextStyle(color: AppColors.darkBlueGray),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu teléfono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              if (!_isEditing) ...[
                ListTile(
                  leading: const Icon(
                    Icons.star_outline,
                    color: AppColors.blue,
                  ),
                  title: const Text(
                    'Calificación',
                    style: TextStyle(color: AppColors.deepBlue),
                  ),
                  subtitle: Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      );
                    }),
                  ),
                ),
                const ListTile(
                  leading: Icon(
                    Icons.directions_car_outlined,
                    color: AppColors.blue,
                  ),
                  title: Text(
                    'Viajes completados',
                    style: TextStyle(color: AppColors.deepBlue),
                  ),
                  trailing: Text(
                    '42',
                    style: TextStyle(color: AppColors.darkBlueGray),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.access_time, color: AppColors.blue),
                  title: Text(
                    'Miembro desde',
                    style: TextStyle(color: AppColors.deepBlue),
                  ),
                  trailing: Text(
                    'Marzo 2025',
                    style: TextStyle(color: AppColors.darkBlueGray),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
