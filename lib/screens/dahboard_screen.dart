import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/screens/post_detail_screen.dart';
import 'package:hackathon/screens/post_screen.dart';
import 'package:hackathon/utils/colors.dart';
import 'package:hackathon/utils/fontstyle.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<DashboardScreen> {
  // 게시글들을 올리기 위한 product
  final product = FirebaseFirestore.instance
      .collection('posts')
      .orderBy('publishedDate', descending: true);

  String getMeetingDateString(DateTime meetingDate, Duration difference) {
    if (difference.inDays == 0) {
      return "오늘";
    }
    if (difference.inDays == 1) {
      return "내일";
    }
    if (difference.inDays == 2) {
      return "모레";
    } else {
      return "${meetingDate.month}/${meetingDate.day}";
    }
  }

  String getMeetingTimeString(DateTime meetingDate) {
    if (meetingDate.hour > 12) {
      return " 오후 ${meetingDate.hour - 12}시${meetingDate.minute}분";
    } else if (meetingDate.hour == 12) {
      return " 오후 ${meetingDate.hour}시${meetingDate.minute}분";
    } else {
      return " 오전 ${meetingDate.hour}시${meetingDate.minute}분";
    }
  }

  Future<List<String>> getCommentProfileImages(String postId) async {
    List<String> profileImages = [];
    QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    commentSnapshot.docs.forEach((comment) {
      profileImages.add(comment['profImage']);
    });

    return profileImages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
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

                //publishedDate와 now의 Differenece
                Duration difference = now.difference(publishedDate);
                //약속날짜와 now의 Difference
                Duration difference2 = meetingDate.difference(now);
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
                      print(difference2.inDays.toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                              postId: documentSnapshot['postId']),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5, // Add elevation to the card
                      child: Padding(
                        padding: const EdgeInsets.all(
                            12.0), // Update the padding value
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: greenColor,
                                          ),
                                          child: Text(
                                            documentSnapshot['category'],
                                            style: bodyText2.copyWith(

                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(getMeetingDateString(
                                          meetingDate, difference2)+ getMeetingTimeString(meetingDate)),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    documentSnapshot['title'],
                                    style: TextStyle(
                                      fontSize: 20, // Update the font size
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    msg,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black
                                          .withOpacity(0.5), // Update the color
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 15),
                                    child: FutureBuilder(
                                      future: getCommentProfileImages(
                                          documentSnapshot['postId']),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<String>> snapshot) {
                                        if (snapshot.hasData) {
                                          List<String> profileImages =
                                              snapshot.data!;
                                          return SizedBox(
                                            height: 40,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: profileImages.length,
                                              itemBuilder: (BuildContext context,
                                                  int index) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 0.0),
                                                  child: CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                        profileImages[index]),
                                                    radius: 11,
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        } else {
                                          return CircularProgressIndicator();
                                        }
                                      },
                                    ),
                                  ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          color: isFull
                                              ? Colors.grey
                                              : primaryColor,
                                        ),
                                        child: Text(
                                          isFull ? "모집 완료" : "모집 중",
                                          style: bodyText2.copyWith(
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 3,),
                                  Text("("+
                                    documentSnapshot['memberList']
                                            .length
                                            .toString() +
                                        "/" +
                                        documentSnapshot['memberNum']
                                            .toString()+")",
                                    style: TextStyle(fontSize: 13),
                                  ),
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
        backgroundColor: blueColor,
      ),
    );
  }
}
