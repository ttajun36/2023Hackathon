import 'dart:typed_data';

import 'package:hackathon/models/users.dart' as model;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hackathon/resources/storage_method.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required Uint8List file,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty) {
        //register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        //이건 사진을 fire sotrage에 집어넣는 함수
        //profilepics라는 폴더를 만들고, uid 폴더를 만들어서
        //file은 Uint8List로 변환한 사진.
        //photoUrl에는 사진의 url 주소가 들어가게 된다.
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        //add user to data base
        //user을 data 안에 저장하는 부분
        //이 부분이 회원가입때 만드는 부분.
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'email' : email,
          'username': username,
          'uid': cred.user!.uid,
          'followers': [],
          'following': [],
          'photoUrl': photoUrl,
        });

        res = "success";
      } else {
        res = "please enter all the field";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Some error occured";

    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the filed";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
