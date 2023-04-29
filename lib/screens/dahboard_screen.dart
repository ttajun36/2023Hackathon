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
    } else if (difference.inDays == 1) {
      return "내일";
    } else if (difference.inDays == 2) {
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
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: Text(
          '같이 해요!',
          style: subtitle3.copyWith(color: Colors.black),
        ),
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
                Duration difference2 = now.difference(meetingDate);
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
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        child: Text(
                                          documentSnapshot['category'],
                                          style: bodyText2.copyWith(
                                            color:
                                                documentSnapshot['category'] ==
                                                        '식사'
                                                    ? Colors.red
                                                    : documentSnapshot[
                                                                'category'] ==
                                                            '스터디'
                                                        ? Colors.green
                                                        : Colors.blue,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 3),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                                text: getMeetingDateString(
                                                    meetingDate, difference2),
                                                style: bodyText2),
                                            TextSpan(
                                              text: getMeetingTimeString(
                                                  meetingDate),
                                              style: bodyText2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(documentSnapshot['title'],
                                      style: headline4),
                                  SizedBox(height: 10),
                                  SizedBox(height: 5),
                                  Text(
                                    msg,
                                    //'Date Published: ${DateFormat('yyyy-MM-dd hh:mm').format(documentSnapshot['date_published'].toDate())}',
                                    style: TextStyle(
                                        fontSize: 12,
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
                                  FutureBuilder(
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
                                                  radius: 10,
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
                                  Row(
                                    children: [
                                      Text(
                                        isFull ? "모집 완료" : "모집 중",
                                        style: bodyText2.copyWith(
                                          color: isFull
                                              ? Colors.blue
                                              : primaryColor,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        documentSnapshot['memberList']
                                                .length
                                                .toString() +
                                            "/" +
                                            documentSnapshot['memberNum']
                                                .toString(),
                                        style: bodyText2,
                                      ),
                                    ],
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
        backgroundColor: primaryColor,
      ),
    );
  }
}
