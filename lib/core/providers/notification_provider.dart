import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UnreadNotificationProvider with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void fetchUnreadCount(String uid) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(uid)
        .collection('userNotifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      _unreadCount = snapshot.docs.length;
      notifyListeners();
    });
  }

  void markAllAsRead(String uid) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(uid)
        .collection('userNotifications')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'isRead': true});
      }
      _unreadCount = 0;
      notifyListeners();
    });
  }
}
