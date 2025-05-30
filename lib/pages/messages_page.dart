import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/loginService.dart';
import 'chat_page.dart';
import '../services/messageService.dart';

class MessagesPage extends StatefulWidget {
  final LoginService loginService;
  final FirebaseFirestore? firestore;

  const MessagesPage({
    Key? key,
    required this.loginService,
    this.firestore,
  }) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  FirebaseFirestore get _firestore =>
      widget.firestore ?? FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = widget.loginService.getCurrentUser()?.email ?? '';
    print('Current user email: $currentUserEmail');

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error in StreamBuilder: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data?.docs ?? [];
          print('Number of messages: ${messages.length}');

          final Map<String, QueryDocumentSnapshot> lastMessages = {};

          for (var doc in messages) {
            final data = doc.data() as Map<String, dynamic>;
            print('Message data: $data');
            final sender = data['sender'] as String;
            final receiver = data['receiver'] as String;

            if (sender == currentUserEmail) {
              if (!lastMessages.containsKey(receiver)) {
                lastMessages[receiver] = doc;
              }
            } else if (receiver == currentUserEmail) {
              if (!lastMessages.containsKey(sender)) {
                lastMessages[sender] = doc;
              }
            }
          }

          final uniquePartners = lastMessages.keys.toList();
          print('Unique partners: $uniquePartners');

          if (uniquePartners.isEmpty) {
            return const Center(child: Text('No messages yet'));
          }

          return ListView.builder(
            itemCount: uniquePartners.length,
            itemBuilder: (context, index) {
              final partner = uniquePartners[index];
              final lastMessage = lastMessages[partner]!;
              final lastMessageData =
                  lastMessage.data() as Map<String, dynamic>;
              final lastMessageText = lastMessageData['message'] as String;
              final timestamp = lastMessageData['timestamp'] as Timestamp?;
              final time = timestamp != null
                  ? '${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                  : '';

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(partner),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lastMessageText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (time.isNotEmpty)
                      Text(time, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        currentUser: currentUserEmail,
                        otherUser: partner,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
