import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> post({
    required String title,
    required String description,
    required DateTime meetingDate,
    required int memberNum,
    required String uid,
    required String username,
    required String profImage,
  }) async {
    String res = "some errors occurred";
    try {
      String postId = const Uuid().v1();

      if (title.isNotEmpty || description.isNotEmpty) {
        DocumentReference postRef =
            _firebaseFirestore.collection('posts').doc(postId);

        await postRef.set({
          'title': title,
          'description': description,
          'meetingDate': meetingDate,
          'memberNum': memberNum,
          'memberList': [uid],
          'uid': uid,
          'username': username,
          'publishedDate': DateTime.now(),
          'postId': postId,
          'profImage': profImage,
        });

        await postRef.collection('comments').add({
          'uid': uid,
          'username': username,
          'profImage': profImage,
        });

        res = "success";
      } else {
        res = "please enter all the filed";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> attendPost(
      {required String uid,
      required String username,
      required String profImage,
      required String postId}) async {
      String res = "some errors occurred";
      try{
          DocumentReference postRef =
            _firebaseFirestore.collection('posts').doc(postId);

        await postRef.update({
            'memberList': FieldValue.arrayUnion([uid]),
          });

        await postRef.collection('comments').doc(uid).set({
            'uid': uid,
            'username': username,
            'profImage': profImage,
          });

          res = "success";
      } catch(err){
        res = err.toString();
      }
      return res;
    }
  }

