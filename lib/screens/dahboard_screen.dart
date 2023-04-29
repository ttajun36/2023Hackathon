import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/screens/post_detail_screen.dart';
import 'package:hackathon/screens/post_screen.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<DashboardScreen> {
  // 게시글들을 올리기 위한 product
  CollectionReference product = FirebaseFirestore.instance.collection('posts');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Cloud Firestore'),
      ),
      body: StreamBuilder(
        stream: product.snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];

                Timestamp timestamp_meeting = documentSnapshot['meetingDate'];
                DateTime meetingDate = timestamp_meeting.toDate();
                Timestamp timestamp_published =
                    documentSnapshot['publishedDate'];
                DateTime publishedDate = timestamp_published.toDate();
                DateTime now = DateTime.now();
                Duration difference = now.difference(publishedDate);
                bool isFull = false;
                if (documentSnapshot['memberList'].length ==
                    documentSnapshot['memberNum']) {
                  isFull = true;
                }

                final String msg;

                if (difference.inDays > 0) {
                  msg = "${difference.inDays}" + "일 전";
                } else if (difference.inHours > 0) {
                  msg = "${difference.inHours}" + "시간 전";
                } else if (difference.inMinutes > 0) {
                  msg = "${difference.inMinutes}" + "분 전";
                } else {
                  msg = "${difference.inSeconds}" + "초 전";
                }
                //이 이후 부터는 그냥 documentSnapshot으로 접근하면 됨.

                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                              postId: documentSnapshot['postId']),
                        ),
                      );
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text(
                                    '${meetingDate.month}/${meetingDate.day}   ${meetingDate.hour}시${meetingDate.minute}분',
                                    //'Date Published: ${DateFormat('yyyy-MM-dd hh:mm').format(documentSnapshot['date_published'].toDate())}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                        documentSnapshot['title'],
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),                     
                                  SizedBox(height: 10),
                                  Text(
                                    msg,
                                    //'Date Published: ${DateFormat('yyyy-MM-dd hh:mm').format(documentSnapshot['date_published'].toDate())}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black.withOpacity(0.3)),
                                  ),                                  
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              // fit: FlexFit.loose,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                 Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color:
                                          isFull ? Colors.blue : Colors.orange,
                                    ),
                                    child: Text(
                                      isFull ? "모집 완료" : "모집 중",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(documentSnapshot['memberList']
                                          .length
                                          .toString() +
                                      "/" +
                                      documentSnapshot['memberNum'].toString()),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ));
              },
            );
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
