
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tr_guide/models/post.dart';
import 'package:tr_guide/services/storage_methods.dart';
import 'package:uuid/uuid.dart';


class FirestoreMethods{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//upload post
Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage,
      {required String location}) async {
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
        location: location,
        postId: postId,
      );
      await _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  

Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });

        // Bildirim ekle
        var postSnap = await _firestore.collection('posts').doc(postId).get();
        var postOwnerId = postSnap['uid'];
        var userSnap = await _firestore.collection('users').doc(uid).get();
        var name = userSnap['name'];
        var userProfileImg = userSnap['photoUrl'];

        if (postOwnerId != uid) {
          await addNotification(
              postOwnerId, 'like', postId, name, userProfileImg);
        }
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }


// Method to get post count by user ID
  Future<int> getUserPostCount(String uid) async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('posts').where('uid', isEqualTo: uid).get();

    return querySnapshot.docs.length;
  }
Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  
Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });

        // Bildirim ekle
        var userSnap = await _firestore.collection('users').doc(uid).get();
        var name = userSnap['name'];
        var userProfileImg = userSnap['photoUrl'];

        if (followId != uid) {
          await addNotification(
              followId, 'follow', '', name, userProfileImg);
        }
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  Future<void> addNotification(String userId, String type, String postId,
      String name, String userProfileImg) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .add({
        'type': type,
        'userId': userId,
        'name': name,
        'userProfileImg': userProfileImg,
        'postId': postId,
        'datePublished': DateTime.now(),
        'isRead': false, 
      });
    } catch (e) {
      print(e.toString());
    }
  }

}
