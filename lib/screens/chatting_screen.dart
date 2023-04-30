import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/screens/realChat_screen.dart';
import 'package:intl/intl.dart';

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
        title: Text("Chats"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
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
                String chatId = chattingList[chattingList.length - index - 1];

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
                      String hostUser = chatDoc['hostUser'];
                      Timestamp timestamp = chatDoc['meetingDate'];
                      DateTime meetingDate = timestamp.toDate();
                      String formattedMeetingDate =
                          DateFormat('M월 d일 (E)', 'ko')
                              .add_jm()
                              .format(meetingDate);
                      String hostImage = chatDoc['hostImage'];

                      return Card(
                        margin: EdgeInsets.all(3),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(2),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(hostImage),
                            radius: 30,
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(
                                hostUser,
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 5),
                              Text(
                                formattedMeetingDate,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RealChatScreen(chatId: chatId),
                              ),
                            );
                          },
                        ),
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
