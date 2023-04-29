import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hackathon/screens/profile_screen.dart';
import 'package:provider/provider.dart';

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

    return Scaffold(
        appBar: AppBar(
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
                  // 여기에서 post 데이터를 사용하여 UI를 구성합니다.

                  // 이이후 부터는 그냥 post로 접근 가능
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(uid: post['uid']),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(post['profImage']),
                            radius: 50.0,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          post['title'],
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          post['description'],
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
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
                                  return ListTile(
                                    leading: GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileScreen(uid: commentDoc['uid']),),);
                                      },
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            commentDoc['profImage']),
                                      ),
                                    ),
                                    title: Text(commentDoc['username']),
                                  );
                                },
                              );
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ],
                    ),
                  );
                  ; // 제목을 표시합니다.
                }
                return CircularProgressIndicator();
              },
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  attendPost(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  );
                },
                child: Text("Attend"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ));
  }
}
