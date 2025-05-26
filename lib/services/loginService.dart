import 'package:firebase_auth/firebase_auth.dart';

// Servicio para manejar la autenticación de usuarios
class LoginService {
  final FirebaseAuth _auth;

  LoginService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  // Iniciar sesión con teléfono y contraseña
  Future<User?> signInWithPhoneAndPassword(
    String phone,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: "$phone@triplo.com", // Usa el teléfono como parte del email
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error de inicio de sesión: ${e.code} - ${e.message}');
      return null;
    }
  }

  // Registrar nuevo usuario con teléfono y contraseña
  Future<User?> registerWithPhoneAndPassword(
    String phone,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: "$phone@triplo.com", // Usa el teléfono como parte del email
            password: password,
          );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Error de registro: ${e.code} - ${e.message}');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
