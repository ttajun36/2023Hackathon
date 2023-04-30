import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackathon/screens/profile_screen.dart';
import 'package:hackathon/utils/colors.dart';
import 'package:hackathon/utils/fontstyle.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({required this.postId});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Future<DocumentSnapshot> _post;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko', null);
    _post =
        FirebaseFirestore.instance.collection('posts').doc(widget.postId).get();
  }

  void attendPost(String uid, String username, String profImage) async {
    String res = await FirestoreMethods().attendPost(
        postId: widget.postId,
        uid: uid,
        username: username,
        profImage: profImage);
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    bool _isMember = false;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.black,
          title: Text('Post Detail'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder(
              future: _post,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  DocumentSnapshot post = snapshot.data!;
                  Timestamp timestamp = post['meetingDate'];
                  DateTime dateTime = timestamp.toDate();
                  String format_meetingDate =
                      DateFormat('M월 d일 (E)', 'ko').add_jm().format(dateTime);
                  // 여기에서 post 데이터를 사용하여 UI를 구성합니다.

                  if (post['memberList'].contains(userProvider.getUser.uid)) {
                    _isMember = true;
                  } else {
                    _isMember = false;
                  }

                  // 이이후 부터는 그냥 post로 접근 가능
                  return Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 17),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 30),
                                  Text(
                                    post['title'],
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    format_meetingDate,
                                    style: TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.room_outlined),
                                      Text(
                                        post['category'],
                                        style: TextStyle(
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: 350), // 최대 너비를 설정하세요.
                                    child: Text(
                                      post['description'],
                                      style: TextStyle(fontSize: 18),
                                      softWrap: true, // 자동으로 줄 바꿈이 되도록 설정
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                        //댓글 구현

                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('posts')
                              .doc(widget.postId)
                              .collection('comments')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> commentSnapshot) {
                            if (commentSnapshot.hasData) {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: commentSnapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final DocumentSnapshot commentDoc =
                                      commentSnapshot.data!.docs[index];
                                  // return ListTile(
                                  //   leading: GestureDetector(
                                  //     onTap: () {
                                  //       Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //           builder: (context) => ProfileScreen(
                                  //               uid: commentDoc['uid']),
                                  //         ),
                                  //       );
                                  //     },
                                  //     child: CircleAvatar(
                                  //       backgroundImage: NetworkImage(
                                  //           commentDoc['profImage']),

                                  if (commentDoc['uid'] == post['uid']) {
                                    return ListTile(
                                      leading: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileScreen(
                                                      uid: commentDoc['uid']),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              commentDoc['profImage']),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Text(commentDoc['username']),
                                          Icon(Icons.star_rounded),
                                          Text('chief',
                                              style: TextStyle(
                                                  color: Colors.black
                                                      .withOpacity(0.3)))
                                        ],
                                      ),
                                    );
                                  } else {
                                    return ListTile(
                                      leading: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileScreen(
                                                      uid: commentDoc['uid']),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              commentDoc['profImage']),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Text(commentDoc['username']),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ],
                    ),
                  );
                  // 제목을 표시합니다.
                }
                return CircularProgressIndicator();
              },
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(5),
              child: ElevatedButton(
                onPressed: () {
                  if (!_isMember) {
                    attendPost(
                      userProvider.getUser.uid,
                      userProvider.getUser.username,
                      userProvider.getUser.photoUrl,
                    );
                  } else {
                    print('nope');
                  }
                },
                child: Text("함께하기"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ));
  }
}
