import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/screens/realChat_screen.dart';

import '../utils/colors.dart';

class ChattingScreen extends StatefulWidget {
  final String uid;
  const ChattingScreen({required this.uid});

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
  late Stream<DocumentSnapshot> _chattingStream;

  @override
  void initState() {
    super.initState();
    _chattingStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black,
        title: Text("Chats"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _chattingStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            DocumentSnapshot userDoc = snapshot.data!;
            List<dynamic> chattingList = userDoc['chattingList'];

            return ListView.builder(
              itemCount: chattingList.length,
              itemBuilder: (context, index) {
                String chatId = chattingList[index];

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> chatSnapshot) {
                    if (chatSnapshot.connectionState ==
                        ConnectionState.active) {
                      if (chatSnapshot.hasError) {
                        return Text('Error: ${chatSnapshot.error}');
                      }

                      DocumentSnapshot chatDoc = chatSnapshot.data!;
                      String title = chatDoc['title'];

                      return ListTile(
                        title: Text(title),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RealChatScreen(chatId: chatId),
                            ),
                          );
                        },
                      );
                    }
                    return CircularProgressIndicator();
                  },
                );
              },
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
