//post model
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String location;
  final String description;
  final String uid;
  final String name;
  final String postId;
  final String photoUrl;
  final String postPhotoUrl;
  final List likes;
  final DateTime datePublished;

  Post(
      {required this.uid,
      required this.name,
      required this.photoUrl,
      required this.postPhotoUrl,
      required this.likes,
      required this.datePublished,
      required this.location,
      required this.description,
      required this.postId});

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      name: snapshot["name"],
      uid: snapshot["uid"],
      photoUrl: snapshot["photoUrl"],
      postPhotoUrl: snapshot["postPhotoUrl"],
      likes: snapshot["likes"],
      datePublished: (snapshot["datePublished"] as Timestamp).toDate(),
      location: snapshot["location"],
      postId: snapshot["postId"],
      description: snapshot["description"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "uid": uid,
        "photoUrl": photoUrl,
        "postPhotoUrl": postPhotoUrl,
        "likes": likes,
        "datePublished": datePublished,
        "location": location,
        "postId": postId,
        "description": description,
      };
}
