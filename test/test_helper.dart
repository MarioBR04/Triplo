import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebasePlatform extends FirebasePlatform {
  final _apps = <String, FirebaseAppPlatform>{};

  @override
  bool get isAutomaticDataCollectionEnabled => true;

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    if (!_apps.containsKey(name)) {
      _apps[name] = MockFirebaseAppPlatform();
    }
    return _apps[name]!;
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;
    if (!_apps.containsKey(appName)) {
      _apps[appName] = MockFirebaseAppPlatform();
    }
    return _apps[appName]!;
  }

  @override
  List<FirebaseAppPlatform> get apps => _apps.values.toList();
}

class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform()
      : super(
          defaultFirebaseAppName,
          const FirebaseOptions(
            apiKey: 'mock-api-key',
            appId: 'mock-app-id',
            messagingSenderId: 'mock-sender-id',
            projectId: 'mock-project-id',
          ),
        );

  @override
  String get name => defaultFirebaseAppName;
}

class TestHelper {
  static Future<void> setupFirebaseForTesting() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Set up the mock platform
    FirebasePlatform.instance = MockFirebasePlatform();
  }

  static FakeFirebaseFirestore getFakeFirestore() {
    return FakeFirebaseFirestore();
  }
}
