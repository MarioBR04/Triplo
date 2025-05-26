import 'package:flutter/material.dart';
import '../core/constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _selectedLanguage = 'Español';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.notifications, color: AppColors.blue),
            title: const Text(
              'Notificaciones',
              style: TextStyle(color: AppColors.deepBlue),
            ),
            subtitle: const Text(
              'Recibir alertas y mensajes',
              style: TextStyle(color: AppColors.darkBlueGray),
            ),
            trailing: Switch(
              value: _notificationsEnabled,
              activeColor: AppColors.blue,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on, color: AppColors.blue),
            title: const Text(
              'Ubicación',
              style: TextStyle(color: AppColors.deepBlue),
            ),
            subtitle: const Text(
              'Permitir acceso a la ubicación',
              style: TextStyle(color: AppColors.darkBlueGray),
            ),
            trailing: Switch(
              value: _locationEnabled,
              activeColor: AppColors.blue,
              onChanged: (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.blue),
            title: const Text(
              'Idioma',
              style: TextStyle(color: AppColors.deepBlue),
            ),
            subtitle: Text(
              _selectedLanguage,
              style: const TextStyle(color: AppColors.darkBlueGray),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => SimpleDialog(
                      title: const Text('Seleccionar idioma'),
                      children: [
                        SimpleDialogOption(
                          onPressed: () {
                            setState(() {
                              _selectedLanguage = 'Español';
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Español'),
                        ),
                        SimpleDialogOption(
                          onPressed: () {
                            setState(() {
                              _selectedLanguage = 'English';
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('English'),
                        ),
                      ],
                    ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help, color: AppColors.blue),
            title: const Text(
              'Ayuda',
              style: TextStyle(color: AppColors.deepBlue),
            ),
            onTap: () {
              // TODO: Implementar página de ayuda
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: AppColors.blue),
            title: const Text(
              'Acerca de',
              style: TextStyle(color: AppColors.deepBlue),
            ),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Triplo',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Triplo',
              );
            },
          ),
        ],
      ),
    );
  }
}
