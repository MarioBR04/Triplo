import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  final FirebaseFirestore _firestore;

  MessageService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static String getConversationId(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort();
    return ids.join('_');
  }

  static Future<void> updateExistingMessages() async {}

  Future<void> sendMessage({
    required String sender,
    required String receiver,
    required String message,
  }) async {
    if (sender.isEmpty || receiver.isEmpty) {
      throw ArgumentError('Sender and receiver cannot be empty');
    }
    if (message.isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }

    final String conversationId = getConversationId(sender, receiver);

    await _firestore.collection('messages').add({
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'conversationId': conversationId,
    });
  }

  Stream<QuerySnapshot> getMessages(String user1, String user2) {
    if (user1.isEmpty || user2.isEmpty) {
      throw ArgumentError('User IDs cannot be empty');
    }

    final String conversationId = getConversationId(user1, user2);

    return _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> deleteMessage(String messageId) async {
    if (messageId.isEmpty) {
      throw ArgumentError('Message ID cannot be empty');
    }

    await _firestore.collection('messages').doc(messageId).delete();
  }
}
