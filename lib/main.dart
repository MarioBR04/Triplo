import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'services/loginService.dart';

// Punto de entrada de la aplicación
void main() async {
  // Inicializa Flutter y Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// Widget principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loginService = LoginService();

    return MaterialApp(
      title: 'Triplo',
      // Configuración del tema de la aplicación
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Determina la página inicial según el estado de autenticación
      home:
          loginService.getCurrentUser() != null
              ? const HomePage()
              : const LoginPage(),
      // Rutas principales de la aplicación
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
