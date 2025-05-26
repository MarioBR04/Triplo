import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/loginService.dart';
import '../pages/home.dart';
import '../pages/messages_page.dart';
import '../pages/schedule_trip_page.dart';
import '../pages/travel_history_page.dart';
import '../pages/settings_page.dart';
import '../pages/profile_page.dart';
import '../pages/driver_mode_page.dart';

// Menú lateral de la aplicación
class Sidebar extends StatelessWidget {
  final LoginService loginService;

  const Sidebar({Key? key, required this.loginService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Encabezado del menú con logo y perfil
            Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'triplo',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Información del usuario actual
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.white,
                          radius: 16,
                          child: Icon(
                            Icons.person,
                            color: AppColors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loginService.getCurrentUser()?.email?.split('@')[0] ??
                              'User',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Opciones principales del menú
            ListTile(
              leading: const Icon(
                Icons.add_circle_outline,
                color: AppColors.blue,
              ),
              title: const Text(
                'New Trip',
                style: TextStyle(color: AppColors.deepBlue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: AppColors.blue),
              title: const Text(
                'Schedule Trip',
                style: TextStyle(color: AppColors.deepBlue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduleTripPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.blue),
              title: const Text(
                'Travel History',
                style: TextStyle(color: AppColors.deepBlue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TravelHistoryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.blue),
              title: const Text(
                'Settings',
                style: TextStyle(color: AppColors.deepBlue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.blue),
              title: const Text(
                'My Profile',
                style: TextStyle(color: AppColors.deepBlue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.drive_eta_outlined,
                color: AppColors.blue,
              ),
              title: const Text(
                'Driver Mode',
                style: TextStyle(color: AppColors.deepBlue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverModePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.message_outlined,
                color: AppColors.blue,
              ),
              title: const Text(
                'Messages',
                style: TextStyle(color: AppColors.deepBlue),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MessagesPage(loginService: loginService),
                  ),
                );
              },
            ),
            const Divider(color: AppColors.lightGray),
            // Opción para cerrar sesión
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.blue),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.deepBlue),
              ),
              onTap: () async {
                await loginService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
