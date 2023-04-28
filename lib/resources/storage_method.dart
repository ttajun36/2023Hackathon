import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //adding image to firebase storage
  //"childName" folder -> "uid" folder -> image store!!
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    //creating folder
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    //사진을 profilepics/uid/안에 집어넣고
    //snap을 만든 뒤, url을 리턴
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}
