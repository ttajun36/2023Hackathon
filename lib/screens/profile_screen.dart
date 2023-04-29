import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

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

  //수정하기.
  Future<void> editUserAttribute(
      BuildContext context, String attributeName, String currentValue) async {
    TextEditingController attributeController = TextEditingController();
    attributeController.text = currentValue;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('수정하기'),
          content: TextField(
            controller: attributeController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: attributeName,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Firestore 내에 있는 attributeName을 update
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .update({attributeName: attributeController.text});

                // UI 갱신
                setState(() {
                  _user = FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .get();
                });

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 250),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          user['userCoverImage'],
                          fit: BoxFit.cover,
                          height: 250,
                          width: double.infinity,
                        ),
                        Transform.translate(
                          offset: Offset(
                              0, 40), // 이 값의 y 좌표를 조절하여 프로필 이미지를 아래로 이동시킵니다.
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0, // 테두리 두께를 조절하려면 이 값을 변경하세요.
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundImage: NetworkImage(user['photoUrl']),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: user['username'],
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' (${user['userage'].toString()})',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user['usermajor'],
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 10),
                        Text(
                          user['userID'].toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            // 블로그 아이콘을 클릭했을 때 실행되는 코드
                          },
                          child: Icon(
                            FontAwesomeIcons.blog,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            // 인스타그램 아이콘을 클릭했을 때 실행되는 코드
                          },
                          child: Icon(
                            FontAwesomeIcons.instagram,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 20),
                        InkWell(
                          onTap: () {
                            // 유튜브 아이콘을 클릭했을 때 실행되는 코드
                          },
                          child: Icon(
                            FontAwesomeIcons.youtube,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        if (userProvider.getUser.uid == widget.uid) {
                          await editUserAttribute(context, 'userDescription',
                              user['userDescription']);
                        } else {
                          print('different');
                        }
                      },
                      child: Text(
                        user['userDescription'],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    // 여기에 추가적인 UI 요소를 배치할 수 있습니다.
                  ],
                ),
              ),
            );
            // 제목을 표시합니다.
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
}
