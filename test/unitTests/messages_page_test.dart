import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:triplo/pages/messages_page.dart';
import 'package:triplo/pages/chat_page.dart';
import 'package:triplo/services/loginService.dart';
import '../test_helper.dart';

class MockLoginService extends Mock implements LoginService {}

class MockUser extends Mock implements User {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockLoginService mockLoginService;
  late MockUser mockUser;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockSnapshot;
  late MockQueryDocumentSnapshot mockDoc;

  setUpAll(() async {
    await TestHelper.setupFirebaseForTesting();
  });

  setUp(() {
    mockLoginService = MockLoginService();
    mockUser = MockUser();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockQuery = MockQuery();
    mockSnapshot = MockQuerySnapshot();
    mockDoc = MockQueryDocumentSnapshot();

    when(() => mockUser.email).thenReturn('user1@example.com');
    when(() => mockLoginService.getCurrentUser()).thenReturn(mockUser);
    when(() => mockFirestore.collection('messages')).thenReturn(mockCollection);
    when(() => mockCollection.orderBy('timestamp', descending: true))
        .thenReturn(mockQuery);
    when(() => mockQuery.snapshots())
        .thenAnswer((_) => Stream.value(mockSnapshot));
    when(() => mockSnapshot.docs).thenReturn([mockDoc]);
    when(() => mockDoc.data()).thenReturn({
      'sender': 'user1@example.com',
      'receiver': 'user2@example.com',
      'message': 'Test message',
      'timestamp': Timestamp.now(),
    });
  });

  testWidgets('MessagesPage shows loading indicator initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MessagesPage(
          loginService: mockLoginService,
          firestore: mockFirestore,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('MessagesPage shows empty state when no messages',
      (WidgetTester tester) async {
    when(() => mockSnapshot.docs).thenReturn([]);

    await tester.pumpWidget(
      MaterialApp(
        home: MessagesPage(
          loginService: mockLoginService,
          firestore: mockFirestore,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('No messages yet'), findsOneWidget);
  });

  testWidgets('MessagesPage displays conversations correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MessagesPage(
          loginService: mockLoginService,
          firestore: mockFirestore,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('user2@example.com'), findsOneWidget);
    expect(find.text('Test message'), findsOneWidget);
  });

  testWidgets('MessagesPage navigates to chat on conversation tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MessagesPage(
          loginService: mockLoginService,
          firestore: mockFirestore,
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('user2@example.com'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatPage), findsOneWidget);
  });

  testWidgets('MessagesPage shows error state', (WidgetTester tester) async {
    when(() => mockQuery.snapshots())
        .thenAnswer((_) => Stream.error('Test error'));

    await tester.pumpWidget(
      MaterialApp(
        home: MessagesPage(
          loginService: mockLoginService,
          firestore: mockFirestore,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Error: Test error'), findsOneWidget);
  });

  testWidgets('MessagesPage updates when new conversation arrives',
      (WidgetTester tester) async {
    final controller = StreamController<QuerySnapshot<Map<String, dynamic>>>();
    when(() => mockQuery.snapshots()).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(
      MaterialApp(
        home: MessagesPage(
          loginService: mockLoginService,
          firestore: mockFirestore,
        ),
      ),
    );

    await tester.pump();

    controller.add(mockSnapshot);
    await tester.pump();

    expect(find.text('user2@example.com'), findsOneWidget);
    expect(find.text('Test message'), findsOneWidget);

    controller.close();
  });

  testWidgets('MessagesPage shows timestamp correctly',
      (WidgetTester tester) async {
    final now = DateTime.now();
    when(() => mockDoc.data()).thenReturn({
      'sender': 'user1@example.com',
      'receiver': 'user2@example.com',
      'message': 'Test message',
      'timestamp': Timestamp.fromDate(now),
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MessagesPage(
          loginService: mockLoginService,
          firestore: mockFirestore,
        ),
      ),
    );

    await tester.pump();

    final expectedTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    expect(find.text(expectedTime), findsOneWidget);
  });
}
