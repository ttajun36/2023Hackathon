import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/screens/post_detail_screen.dart';
import 'package:hackathon/screens/post_screen.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

///////////테스트니까 이 주석 지워
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

                //이 이후 부터는 그냥 documentSnapshot으로 접근하면 됨.

                double participationRate =
                    (documentSnapshot['memberList'].length /
                        documentSnapshot['memberNum']);
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              documentSnapshot['title'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Participation: ${(participationRate * 100).toStringAsFixed(2)}%',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'date published',
                              //'Date Published: ${DateFormat('yyyy-MM-dd hh:mm').format(documentSnapshot['date_published'].toDate())}',
                              style: TextStyle(fontSize: 16),
                            ),
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
