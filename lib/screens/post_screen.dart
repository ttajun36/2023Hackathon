import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../resources/firestore_methods.dart';
import '../utils/colors.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  DateTime _meetingDate = DateTime.now();


  int _memberNum=2;
  String _selectedCategory="2학";

  bool _isLoading = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
  }

  void post(String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });

    String res = await FirestoreMethods().post(
        title: _titleController.text,
        description: _descriptionController.text,
        meetingDate: _meetingDate,
        memberNum: _memberNum,
        uid: uid,
        username: username,
        profImage: profImage,
        category: _selectedCategory);

    setState(() {
      _isLoading = false;
    });
    res = "success";
    if (res == "success") {
      Navigator.pop(context);
    }

    print(res);
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Post',),
        actions: <Widget>[
          TextButton(
              onPressed: () => post(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: primaryColor,
                    ))
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: greenColor,
                      ),
                      child: Text(
                        'POST', style: TextStyle(color: Colors.black),
                      ),
                    ),
                    )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: ['1학', '2학','배달','외식']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                  onPressed: () {
                    Future<DateTime?> selectedDate = showDatePicker(
                      context: context, // context 인수전달
                      initialDate: DateTime.now(), // 초깃값
                      firstDate: DateTime(2021), // 시작일 2021년 1월 1일
                      lastDate: DateTime(2030), // 마지막일 2030년 1월 1일
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          // 따로 정의 하지 않으면 default 값이 설정 됨
                          data: ThemeData.dark(), // 다크테마
                          child: child as Widget,
                        );
                      },
                    );
                    selectedDate.then((dateTime) {
                      if (dateTime != null) {
                        showTimePicker(
                          context: context, // context 인수전달
                          initialTime: TimeOfDay.now(), // 초깃값
                        ).then((time) {
                          if (time != null) {
                            setState(() {
                              _meetingDate = DateTime(
                                dateTime.year,
                                dateTime.month,
                                dateTime.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        });
                      }
                    });
                  },
                  child: Icon(Icons.calendar_today),
                ),
                SizedBox(width: 16),
                DropdownButton<int>(
                  value: _memberNum,
                  items: [2, 3, 4].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _memberNum = newValue;
                      });
                    }
                  },
                )
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              minLines: 5,
              maxLines: 10,
            ),
          ],
        ),
      ),
    );
  }
}
