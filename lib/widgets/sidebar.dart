import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/loginService.dart';
import '../pages/home.dart';

class Sidebar extends StatelessWidget {
  final LoginService loginService;

  const Sidebar({Key? key, required this.loginService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          children: [
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
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  GestureDetector(
                    onTap: () {
                      // Navigate to profile page
                    },
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
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
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('New Trip'),
              onTap: () {
                // Navigate to homePage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule Trip'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to schedule trip page
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Travel History'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to travel history page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings page
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile page
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_eta_outlined),
              title: const Text('Driver Mode'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to driver mode page
              },
            ),
            ListTile(
              leading: const Icon(Icons.message_outlined),
              title: const Text('Messages'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to messages page
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
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
