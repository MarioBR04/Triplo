import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:triplo/services/messageService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../test_helper.dart';

// Mock class para extender MessageService y permitir inyección de dependencias
class TestMessageService extends MessageService {
  final FirebaseFirestore firestore;

  TestMessageService(this.firestore);

  @override
  Future<void> sendMessage({
    required String sender,
    required String receiver,
    required String message,
  }) async {
    final String conversationId = MessageService.getConversationId(
      sender,
      receiver,
    );

    await firestore.collection('messages').add({
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'conversationId': conversationId,
    });
  }
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MessageService messageService;

  setUpAll(() async {
    await TestHelper.setupFirebaseForTesting();
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    messageService = MessageService(firestore: fakeFirestore);
  });

  group('MessageService Tests', () {
    test('getConversationId should sort and join user IDs correctly', () {
      const user1 = 'user1';
      const user2 = 'user2';

      final conversationId = MessageService.getConversationId(user1, user2);
      expect(conversationId, equals('user1_user2'));

      // Test reverse order should give same result
      final conversationId2 = MessageService.getConversationId(user2, user1);
      expect(conversationId2, equals('user1_user2'));
    });

    test('getConversationId should handle same user IDs', () {
      expect(MessageService.getConversationId('user1', 'user1'), 'user1_user1');
    });

    test('getConversationId should handle empty strings', () {
      expect(MessageService.getConversationId('', ''), '_');
    });

    test('sendMessage should store message in Firestore', () async {
      const sender = 'sender123';
      const receiver = 'receiver456';
      const message = 'Test message';

      await messageService.sendMessage(
        sender: sender,
        receiver: receiver,
        message: message,
      );

      final messages = await fakeFirestore
          .collection('messages')
          .where('sender', isEqualTo: sender)
          .get();

      expect(messages.docs.length, 1);
      expect(messages.docs.first.get('message'), message);
      expect(messages.docs.first.get('receiver'), receiver);
      expect(messages.docs.first.get('timestamp'), isNotNull);
      expect(
        messages.docs.first.get('conversationId'),
        MessageService.getConversationId(sender, receiver),
      );
    });

    test('sendMessage should reject empty messages', () async {
      const sender = 'sender123';
      const receiver = 'receiver456';
      const message = '';

      expect(
        () => messageService.sendMessage(
          sender: sender,
          receiver: receiver,
          message: message,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('getMessages should return messages between users', () async {
      const user1 = 'user1';
      const user2 = 'user2';
      final conversationId = MessageService.getConversationId(user1, user2);

      // Add test messages
      await fakeFirestore.collection('messages').add({
        'sender': user1,
        'receiver': user2,
        'message': 'Message 1',
        'timestamp': Timestamp.now(),
        'conversationId': conversationId,
      });

      await fakeFirestore.collection('messages').add({
        'sender': user2,
        'receiver': user1,
        'message': 'Message 2',
        'timestamp': Timestamp.now(),
        'conversationId': conversationId,
      });

      final Stream<QuerySnapshot> messageStream = messageService.getMessages(
        user1,
        user2,
      );
      final QuerySnapshot messages = await messageStream.first;

      expect(messages.docs.length, 2);
      expect(
        messages.docs.any((doc) => doc.get('message') == 'Message 1'),
        true,
      );
      expect(
        messages.docs.any((doc) => doc.get('message') == 'Message 2'),
        true,
      );
    });

    test('sendMessage should handle empty content', () async {
      const sender = 'sender123';
      const receiver = 'receiver456';
      const message = '';

      expect(
        () => messageService.sendMessage(
          sender: sender,
          receiver: receiver,
          message: message,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('getMessages should handle invalid user IDs', () async {
      expect(
        () => messageService.getMessages('', 'user2'),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => messageService.getMessages('user1', ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('messages should be ordered by timestamp', () async {
      const user1 = 'user1';
      const user2 = 'user2';
      final conversationId = MessageService.getConversationId(user1, user2);

      // Add test messages with different timestamps
      await fakeFirestore.collection('messages').add({
        'sender': user1,
        'receiver': user2,
        'message': 'First',
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(1000),
        'conversationId': conversationId,
      });
      await fakeFirestore.collection('messages').add({
        'sender': user2,
        'receiver': user1,
        'message': 'Second',
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(2000),
        'conversationId': conversationId,
      });

      final Stream<QuerySnapshot> messageStream = messageService.getMessages(
        user1,
        user2,
      );
      final QuerySnapshot messages = await messageStream.first;

      expect(messages.docs.length, 2);
      expect(messages.docs[0].get('message'), 'First');
      expect(messages.docs[1].get('message'), 'Second');
    });

    test(
      'sendMessage should throw error for empty sender or receiver',
      () async {
        expect(
          () => messageService.sendMessage(
            sender: '',
            receiver: 'user2',
            message: 'test',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => messageService.sendMessage(
            sender: 'user1',
            receiver: '',
            message: 'test',
          ),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('getMessages should return messages stream', () async {
      const user1 = 'user1';
      const user2 = 'user2';
      final conversationId = MessageService.getConversationId(user1, user2);

      // Add test messages
      await fakeFirestore.collection('messages').add({
        'sender': user1,
        'receiver': user2,
        'message': 'Message 1',
        'timestamp': FieldValue.serverTimestamp(),
        'conversationId': conversationId,
      });

      await fakeFirestore.collection('messages').add({
        'sender': user2,
        'receiver': user1,
        'message': 'Message 2',
        'timestamp': FieldValue.serverTimestamp(),
        'conversationId': conversationId,
      });

      final Stream<QuerySnapshot> messageStream = messageService.getMessages(
        user1,
        user2,
      );
      final QuerySnapshot messages = await messageStream.first;

      expect(messages.docs.length, 2);
      expect(
        messages.docs.any((doc) => doc.get('message') == 'Message 1'),
        true,
      );
      expect(
        messages.docs.any((doc) => doc.get('message') == 'Message 2'),
        true,
      );
    });

    test('deleteMessage should remove message from Firestore', () async {
      // Add a test message
      final docRef = await fakeFirestore.collection('messages').add({
        'sender': 'user1',
        'receiver': 'user2',
        'message': 'Test message',
        'timestamp': FieldValue.serverTimestamp(),
        'conversationId': MessageService.getConversationId('user1', 'user2'),
      });

      // Verify message exists
      var message =
          await fakeFirestore.collection('messages').doc(docRef.id).get();
      expect(message.exists, true);

      // Delete message
      await messageService.deleteMessage(docRef.id);

      // Verify message was deleted
      message = await fakeFirestore.collection('messages').doc(docRef.id).get();
      expect(message.exists, false);
    });

    test('deleteMessage should throw error for empty message ID', () {
      expect(
        () => messageService.deleteMessage(''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
