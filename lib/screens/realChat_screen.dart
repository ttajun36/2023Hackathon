import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class RealChatScreen extends StatefulWidget {
  final String chatId;
  const RealChatScreen({required this.chatId});

  @override
  State<RealChatScreen> createState() => _RealChatScreenState();
}

class _RealChatScreenState extends State<RealChatScreen> {
  late Stream<QuerySnapshot> _chatMessagesStream;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatMessagesStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('realchat')
        .orderBy('chatDate', descending: true)
        .snapshots();
  }

  Future<void> _sendMessage(String message, String uid, String username, String profImage) async {
    if (message.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('realchat')
          .add({
        'uid': uid,
        'username': username,
        'chatting': message,
        'chatDate': Timestamp.now(),
        'profImage': profImage,
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Room"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatMessagesStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  List<DocumentSnapshot> chatMessages = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: chatMessages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot messageDoc = chatMessages[index];
                      String messageText = messageDoc['chatting'];
                      String senderName = messageDoc['username'];
                      String profImage = messageDoc['profImage'];
                      String messageSenderId = messageDoc['uid'];

                      bool isCurrentUser = (messageSenderId == userProvider.getUser.uid);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: isCurrentUser? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: isCurrentUser
                              ? [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(senderName,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(height: 5),
                                      Text(messageText,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(profImage),
                                  ),
                                ]
                              : [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(profImage),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(senderName,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                      SizedBox(height: 5),
                                      Text(messageText,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400)),
                                    ],
                                  ),
                                ],
                        ),
                      );
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {            
                    _sendMessage(_messageController.text, userProvider.getUser.uid, userProvider.getUser.username, userProvider.getUser.photoUrl, );
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
