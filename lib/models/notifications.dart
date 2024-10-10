import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String type;
  final String userId;
  final String name;
  final String userProfileImg;
  final String postId;
  final DateTime datePublished;

  const Notification({
    required this.type,
    required this.userId,
    required this.name,
    required this.userProfileImg,
    required this.postId,
    required this.datePublished,
  });

  static Notification fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Notification(
      type: snapshot['type'],
      userId: snapshot['userId'],
      name: snapshot['name'],
      userProfileImg: snapshot['userProfileImg'],
      postId: snapshot['postId'],
      datePublished: (snapshot['datePublished'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'userId': userId,
        'name': name,
        'userProfileImg': userProfileImg,
        'postId': postId,
        'datePublished': datePublished,
      };
}
