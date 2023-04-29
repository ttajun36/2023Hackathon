import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../resources/storage_method.dart';
import '../utils/utils.dart';

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

  Future<void> _updateCoverImage(BuildContext context) async {
    // 이미지 선택
    Uint8List? pickedImage = await pickImage(ImageSource.gallery);
    if (pickedImage != null) {
      // StorageMethods 인스턴스 생성
      StorageMethods storageMethods = StorageMethods();

      // 업로드 후 다운로드 URL 받기
      String downloadUrl = await storageMethods.uploadImageToStorage(
          "userCoverImages", pickedImage, true);

      // Firestore 업데이트
      FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        'userCoverImage': downloadUrl,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cover image updated successfully"),
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update cover image: $error"),
          ),
        );
      });

      setState(() {
        _user = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .get();
      });
    }
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

  Future<void> addProperty(BuildContext context, int status) async {
    TextEditingController propertyController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: status == 0
              ? Text('책 추가하기')
              : status == 1
                  ? Text('관심 분야 추가하기')
                  : Text('좋아하는 음악 추가하기'),
          content: TextField(
            controller: propertyController,
            decoration: InputDecoration(
              labelText: status == 0
                  ? '책 제목'
                  : status == 1
                      ? '관심 분야'
                      : '좋아하는 음악',
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
                // Firestore 내에 있는 interested 배열에 추가
                if (status == 0) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .update({
                    'book': FieldValue.arrayUnion([propertyController.text])
                  });
                } else if (status == 1) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .update({
                    'interested':
                        FieldValue.arrayUnion([propertyController.text])
                  });
                } else {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .update({
                    'music': FieldValue.arrayUnion([propertyController.text])
                  });
                }

                // UI 갱신
                setState(() {
                  _user = FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .get();
                });

                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    TextStyle sectionTitleStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    TextStyle itemTextStyle = TextStyle(
      fontSize: 18,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _user,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              DocumentSnapshot user = snapshot.data!;
              // 여기에서 user 데이터를 사용하여 UI를 구성합니다.
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              InkWell(
                                onTap: () => _updateCoverImage(context),
                                child: Image.network(
                                  user['userCoverImage'],
                                  fit: BoxFit.cover,
                                  height: 250,
                                  width: double.infinity,
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0,
                                    40), // 이 값의 y 좌표를 조절하여 프로필 이미지를 아래로 이동시킵니다.
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
                                    backgroundImage:
                                        NetworkImage(user['photoUrl']),
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
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
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
                                await editUserAttribute(context,
                                    'userDescription', user['userDescription']);
                              } else {
                                print('different');
                              }
                            },
                            child: Text(
                              user['userDescription'],
                              maxLines: 3, // 추가된 속성
                              overflow: TextOverflow.ellipsis, // 추가된 속성
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          // 여기에 추가적인 UI 요소를 배치할 수 있습니다.
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.book,
                              color: Colors.blueGrey,
                              size: 24,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              // 이 부분을 추가합니다.
                              onTap: () {
                                addProperty(context, 0);
                              },
                              child: Text(
                                '인상 깊게 읽은 책',
                                style: sectionTitleStyle,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 20, // 간격 설정
                          children: user['book']
                              .map<Widget>((book) => Text(
                                    "'$book'",
                                    style: itemTextStyle,
                                  ))
                              .toList(),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.lightbulb,
                              color: Colors.blueGrey,
                              size: 24,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: () {
                                addProperty(context, 1);
                              },
                              child: Text(
                                '관심 분야',
                                style: sectionTitleStyle,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 20, // 간격 설정
                          children: user['interested']
                              .map<Widget>((interest) => Text(
                                    "'$interest'",
                                    style: itemTextStyle,
                                  ))
                              .toList(),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.music,
                              color: Colors.blueGrey,
                              size: 24,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: () {
                                addProperty(context,2);
                              },
                              child: Text(
                                '좋아하는 음악',
                                style: sectionTitleStyle,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 20, // 간격 설정
                          children: user['music']
                              .map<Widget>((music) => Text(
                                    "'$music'",
                                    style: itemTextStyle,
                                  ))
                              .toList(),
                        ),
                        // 여기에 추가적인 UI 요소를 배치할 수 있습니다.
                      ],
                    ),
                  ),
                ],
              );
              // 제목을 표시합니다.
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
