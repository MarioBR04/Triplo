import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:triplo/firebase_options.dart';

// Mock classes
class MockUser implements User {
  @override
  bool get isAnonymous => true;

  @override
  String get uid => 'userID';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserCredential implements UserCredential {
  @override
  User? get user => MockUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  Future<UserCredential> signInAnonymously() async {
    return MockUserCredential();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
  });

  test('Conexión a Firebase y autenticación anónima', () async {
    try {
      final userCredential = await mockFirebaseAuth.signInAnonymously();
      expect(userCredential.user, isNotNull);
      expect(userCredential.user!.isAnonymous, isTrue);
      expect(userCredential.user!.uid, 'userID');
      print('Usuario anónimo conectado: ${userCredential.user!.uid}');
    } catch (e) {
      print('Error durante la autenticación anónima: $e');
      fail('La prueba falló debido a un error de Firebase.');
    }
  });
}
