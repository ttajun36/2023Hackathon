import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({required this.uid});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<DocumentSnapshot> _user;

  @override
  void initState() {
    super.initState();
    _user =
        FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Detail'),
      ),
      body: FutureBuilder(
        future: _user,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            DocumentSnapshot user = snapshot.data!;
            // 여기에서 user 데이터를 사용하여 UI를 구성합니다.
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [            
                  Text(
                    user['username'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    user['bio'],
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  // 여기에 추가적인 UI 요소를 배치할 수 있습니다.
                ],
              ),
            );
            ; // 제목을 표시합니다.
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
}
