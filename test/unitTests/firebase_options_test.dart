import 'package:flutter_test/flutter_test.dart';
import 'package:triplo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    test('currentPlatform returns valid FirebaseOptions', () {
      final options = DefaultFirebaseOptions.currentPlatform;
      expect(options, isA<FirebaseOptions>());
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
      expect(options.messagingSenderId, isNotEmpty);
      expect(options.projectId, isNotEmpty);
    });

    test('ios returns valid FirebaseOptions', () {
      final options = DefaultFirebaseOptions.ios;
      expect(options, isA<FirebaseOptions>());
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
      expect(options.messagingSenderId, isNotEmpty);
      expect(options.projectId, isNotEmpty);
      expect(options.iosBundleId, isNotEmpty);
    });

    test('android returns valid FirebaseOptions', () {
      final options = DefaultFirebaseOptions.android;
      expect(options, isA<FirebaseOptions>());
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
      expect(options.messagingSenderId, isNotEmpty);
      expect(options.projectId, isNotEmpty);
      // androidClientId is optional
      if (options.androidClientId != null) {
        expect(options.androidClientId, isNotEmpty);
      }
    });
  });
}
