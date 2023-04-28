import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/providers/user_provider.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedNumber;
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
    print(uid);
    print(username);
    print(profImage);

    setState(() {
      _isLoading = true;
    });
    /*
    String res = await AuthMethods().post(
      title: _titleController.text,
      password: _descriptionController.text,
      username: ,
    );
    */
    setState(() {
      _isLoading = false;
    });
    String res = "success2";
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
        title: Text(
          'POST',
        ),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
              onPressed: () => post(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
              child: Text(
                'Post',
                style: TextStyle(color: Colors.white),
              ))
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
                ElevatedButton(
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
                              _selectedDate = DateTime(
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
                  value: _selectedNumber,
                  items:
                      [2, 3, 4, 5, 6].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedNumber = newValue;
                    });
                  },
                ),
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
