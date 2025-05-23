import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:triplo/services/loginService.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_core/firebase_core.dart';
import '../Firebase/firebase_test_helper.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<UserCredential>(),
  MockSpec<User>(),
])
import 'login_service_test.mocks.dart';

void main() {
  late LoginService loginService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setupFirebaseTestMocks();
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    loginService = LoginService(mockFirebaseAuth);

    // Setup default responses
    when(mockUserCredential.user).thenReturn(mockUser);
  });

  group('LoginService', () {
    test('signInWithPhoneAndPassword success', () async {
      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: '+1234567890@triplo.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockUserCredential);

      final result = await loginService.signInWithPhoneAndPassword(
        '+1234567890',
        'password123',
      );

      expect(result, equals(mockUser));
      verify(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: '+1234567890@triplo.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('signInWithPhoneAndPassword failure', () async {
      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: '+1234567890@triplo.com',
          password: 'password123',
        ),
      ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      final result = await loginService.signInWithPhoneAndPassword(
        '+1234567890',
        'password123',
      );

      expect(result, isNull);
    });

    test('registerWithPhoneAndPassword success', () async {
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: '+1234567890@triplo.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockUserCredential);

      final result = await loginService.registerWithPhoneAndPassword(
        '+1234567890',
        'password123',
      );

      expect(result, equals(mockUser));
      verify(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: '+1234567890@triplo.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('registerWithPhoneAndPassword failure', () async {
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: '+1234567890@triplo.com',
          password: 'password123',
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final result = await loginService.registerWithPhoneAndPassword(
        '+1234567890',
        'password123',
      );

      expect(result, isNull);
    });

    test('signOut success', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await loginService.signOut();
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('getCurrentUser returns current user', () {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      final user = loginService.getCurrentUser();
      expect(user, equals(mockUser));
    });

    test('getCurrentUser returns null when no user is logged in', () {
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      final user = loginService.getCurrentUser();
      expect(user, isNull);
    });
  });
}
