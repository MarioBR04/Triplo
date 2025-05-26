import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/messageService.dart';

class ChatPage extends StatefulWidget {
  final String currentUser;
  final String otherUser;

  const ChatPage({Key? key, required this.currentUser, required this.otherUser})
    : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    MessageService.updateExistingMessages();
    _updateMessagesWithConversationId();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await MessageService.sendMessage(
      sender: widget.currentUser,
      receiver: widget.otherUser,
      message: _messageController.text.trim(),
    );

    _messageController.clear();
  }

  Stream<QuerySnapshot> _getMessages() {
    final Query query1 = FirebaseFirestore.instance
        .collection('messages')
        .where('sender', isEqualTo: widget.currentUser)
        .where('receiver', isEqualTo: widget.otherUser);

    final Query query2 = FirebaseFirestore.instance
        .collection('messages')
        .where('sender', isEqualTo: widget.otherUser)
        .where('receiver', isEqualTo: widget.currentUser);

    return FirebaseFirestore.instance
        .collection('messages')
        .where(
          'conversationId',
          isEqualTo: '${widget.currentUser}_${widget.otherUser}',
        )
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _updateMessagesWithConversationId() async {
    final String conversationId = '${widget.currentUser}_${widget.otherUser}';

    final QuerySnapshot senderMessages =
        await FirebaseFirestore.instance
            .collection('messages')
            .where('sender', isEqualTo: widget.currentUser)
            .where('receiver', isEqualTo: widget.otherUser)
            .get();

    for (var doc in senderMessages.docs) {
      await doc.reference.update({'conversationId': conversationId});
    }

    final QuerySnapshot receiverMessages =
        await FirebaseFirestore.instance
            .collection('messages')
            .where('sender', isEqualTo: widget.otherUser)
            .where('receiver', isEqualTo: widget.currentUser)
            .get();

    for (var doc in receiverMessages.docs) {
      await doc.reference.update({'conversationId': conversationId});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUser)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessages(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error in chat: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];
                print('Chat messages found: ${messages.length}');

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start a conversation!'),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['sender'] == widget.currentUser;
                    final timestamp = message['timestamp'] as Timestamp?;
                    final time =
                        timestamp != null
                            ? '${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                            : '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['message'] as String,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  time,
                                  style: TextStyle(
                                    color:
                                        isMe ? Colors.white70 : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
