import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tr_guide/models/post.dart';
import 'package:tr_guide/services/storage_methods.dart';
import 'package:uuid/uuid.dart';


class FirestoreMethods{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//upload post
Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1();
      Post post = Post(
          description: description,
          uid: uid,
          name: username,
          photoUrl: profImage,
          postPhotoUrl: photoUrl,
          likes: [],
          datePublished: DateTime.now(),
          location: "",
          postId: postId,
          );
      await _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }






}