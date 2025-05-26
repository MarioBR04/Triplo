import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  static String getConversationId(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort();
    return ids.join('_');
  }

  static Future<void> updateExistingMessages() async {}

  static Future<void> sendMessage({
    required String sender,
    required String receiver,
    required String message,
  }) async {
    final String conversationId = '${sender}_${receiver}';

    await FirebaseFirestore.instance.collection('messages').add({
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'conversationId': conversationId,
    });
  }
}
