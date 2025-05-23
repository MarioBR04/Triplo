import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/mockito.dart';
import 'package:triplo/pages/home.dart';
import 'package:triplo/services/loginService.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../Firebase/firebase_test_helper.dart';

class MockLoginService extends Mock implements LoginService {}

class MockGeolocator extends GeolocatorPlatform {
  static final defaultPosition = Position(
    latitude: 37.42796133580664,
    longitude: -122.085749655962,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    return defaultPosition;
  }
}

void main() {
  late MockGeolocator mockGeolocator;
  late MockLoginService mockLoginService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setupFirebaseTestMocks();
  });

  setUp(() {
    // Set up Geolocator mock
    mockGeolocator = MockGeolocator();
    GeolocatorPlatform.instance = mockGeolocator;

    // Set up login service mock
    mockLoginService = MockLoginService();
  });

  testWidgets('HomePage renders correctly with initial state', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: HomePage(loginService: mockLoginService)),
    );

    // Initial frame should show loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for location permission and map to load
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify UI elements after loading
    expect(find.text('Where you going?'), findsOneWidget);
    expect(find.text('How many are you?'), findsOneWidget);
    expect(find.text('Find Driver'), findsOneWidget);
    expect(find.byType(GoogleMap), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('Can enter destination and passenger count', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: HomePage(loginService: mockLoginService)),
    );

    // Wait for widget to be fully rendered
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Find text fields by key
    final destinationField = find.byKey(const Key('destination_field'));
    final passengerField = find.byKey(const Key('passenger_count_field'));

    // Enter text in fields
    await tester.enterText(destinationField, 'San Francisco');
    await tester.pump();
    await tester.enterText(passengerField, '2');
    await tester.pump();

    // Verify text was entered
    expect(find.text('San Francisco'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Sidebar opens when menu button is tapped', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: HomePage(loginService: mockLoginService)),
    );

    // Wait for widget to be fully rendered
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Find and tap menu button
    final menuButton = find.byKey(const Key('menu_button'));
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pumpAndSettle();

    // Verify drawer is open
    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('New Trip'), findsOneWidget);
    expect(find.text('Schedule Trip'), findsOneWidget);
    expect(find.text('Travel History'), findsOneWidget);
  });

  test('getCurrentLocation returns valid position', () async {
    final position = await mockGeolocator.getCurrentPosition();

    expect(position, isNotNull);
    expect(position.latitude, 37.42796133580664);
    expect(position.longitude, -122.085749655962);
  });
}
