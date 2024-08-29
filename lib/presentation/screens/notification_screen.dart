import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tr_guide/core/providers/notification_provider.dart';
import 'package:tr_guide/core/providers/user_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;
    final unreadNotificationProvider =
        Provider.of<UnreadNotificationProvider>(context);

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .doc(user?.uid)
            .collection('userNotifications')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No notifications yet'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var notiData = snapshot.data!.docs[index];
              var isRead = notiData['isRead'] ?? false;
              var notificationTime = notiData['datePublished'].toDate();

              IconData getNotificationIcon(String type) {
                switch (type) {
                  case 'like':
                    return Icons.favorite;
                  case 'follow':
                    return Icons.person_add;
                  case 'comment':
                    return Icons.comment;
                  default:
                    return Icons.notifications;
                }
              }

              String getNotificationText(String type) {
                switch (type) {
                  case 'like':
                    return 'liked your post';
                  case 'follow':
                    return 'started following you';
                  case 'comment':
                    return 'commented on your post';
                  default:
                    return 'sent you a notification';
                }
              }

              return Column(
                children: [
                  ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          getNotificationIcon(notiData['type']),
                          color: notiData['type'] == 'like'
                              ? const Color.fromARGB(255, 228, 113, 105)
                              : notiData['type'] == 'follow'
                                  ? const Color.fromARGB(144, 33, 149, 243)
                                  : Colors.orange,
                        ),
                        const SizedBox(width: 8), // Boşluk eklemek için
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(notiData['userProfileImg']),
                        ),
                      ],
                    ),
                    title: Text(notiData['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getNotificationText(notiData['type'])),
                        Text(
                          '${DateFormat.yMMMd().format(notificationTime)} at ${DateFormat.Hm().format(notificationTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    tileColor: isRead ? Colors.white : Colors.grey[300],
                    onTap: () {
                      notiData.reference.update({'isRead': true});
                    },
                  ),
                  const Divider(
                    thickness: 0.5,
                  ), // Her bildirimin altına bir çizgi ekle
                ],
              );
            },
          );
        },
      ),
    );
  }
}
