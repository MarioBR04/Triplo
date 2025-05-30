import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:triplo/pages/chat_page.dart';
import 'package:triplo/services/messageService.dart';
import '../test_helper.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MessageService messageService;

  setUp(() async {
    await TestHelper.setupFirebaseForTesting();
    fakeFirestore = TestHelper.getFakeFirestore();
    messageService = MessageService(firestore: fakeFirestore);
  });

  testWidgets('ChatPage shows loading indicator initially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(
          currentUser: 'user1',
          otherUser: 'user2',
          firestore: fakeFirestore,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('ChatPage displays messages correctly', (
    WidgetTester tester,
  ) async {
    // Add some test messages to Firestore
    final conversationId = MessageService.getConversationId('user1', 'user2');

    await fakeFirestore.collection('messages').add({
      'sender': 'user1',
      'receiver': 'user2',
      'message': 'Hello',
      'timestamp': Timestamp.now(),
      'conversationId': conversationId,
    });

    await fakeFirestore.collection('messages').add({
      'sender': 'user2',
      'receiver': 'user1',
      'message': 'Hi there',
      'timestamp': Timestamp.now(),
      'conversationId': conversationId,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(
          currentUser: 'user1',
          otherUser: 'user2',
          firestore: fakeFirestore,
        ),
      ),
    );

    // Wait for StreamBuilder to process the messages
    await tester.pumpAndSettle();

    // Verify messages are displayed
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Hi there'), findsOneWidget);
  });

  testWidgets('ChatPage handles empty message input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(
          currentUser: 'user1',
          otherUser: 'user2',
          firestore: fakeFirestore,
        ),
      ),
    );

    // Wait for initial build
    await tester.pumpAndSettle();

    // Try to send empty message
    final sendButton = find.byIcon(Icons.send);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    // Verify no message is sent (no errors)
    expect(find.text('No messages yet. Start a conversation!'), findsOneWidget);
  });

  testWidgets('ChatPage shows error state', (WidgetTester tester) async {
    // Simulate an error state
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(
          currentUser: '', // Invalid user ID to trigger error
          otherUser: 'user2',
          firestore: fakeFirestore,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('Error:'), findsOneWidget);
  });

  testWidgets('ChatPage updates when new message arrives', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChatPage(
          currentUser: 'user1',
          otherUser: 'user2',
          firestore: fakeFirestore,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Add a new message
    final conversationId = MessageService.getConversationId('user1', 'user2');
    await fakeFirestore.collection('messages').add({
      'sender': 'user2',
      'receiver': 'user1',
      'message': 'New message',
      'timestamp': Timestamp.now(),
      'conversationId': conversationId,
    });

    await tester.pumpAndSettle();

    expect(find.text('New message'), findsOneWidget);
  });
}
