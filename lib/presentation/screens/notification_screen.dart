import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: Colors.white,
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

              IconData? getNotificationIcon(String type) {
                switch (type) {
                  case 'like':
                    return Icons.favorite;
                  case 'follow':
                    return Icons.person_add;
                  case 'travel_plan':
                    return null; // No icon for travel_plan notifications
                  default:
                    return Icons.notifications;
                }
              }

              String getNotificationText(String type) {
                switch (type) {
                  case 'like':
                    return 'liked your post!';
                  case 'follow':
                    return 'started following you!';
                  case 'travel_plan':
                    return 'Your travel recommendations are ready!';
                  default:
                    return 'sent you a notification!';
                }
              }

              String getTimeAgo(DateTime date) {
                final difference = DateTime.now().difference(date);
                if (difference.inMinutes < 60) {
                  return '${difference.inMinutes}m ago';
                } else if (difference.inHours < 24) {
                  return '${difference.inHours}h ago';
                } else {
                  return DateFormat('MMM d').format(date);
                }
              }

              return Column(
                children: [
                  ListTile(
                    leading: notiData['type'] == 'travel_plan'
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(notiData['userProfileImg']),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                getNotificationIcon(notiData['type']),
                                color: notiData['type'] == 'like'
                                    ? const Color.fromARGB(255, 228, 113, 105)
                                    : notiData['type'] == 'follow'
                                        ? const Color.fromARGB(
                                            144, 33, 149, 243)
                                        : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(notiData['userProfileImg']),
                              ),
                            ],
                          ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notiData['type'] != 'travel_plan')
                          Text(
                            notiData['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        Text(getNotificationText(notiData['type'])),
                      ],
                    ),
                    tileColor: isRead ? Colors.white : Colors.grey[300],
                    trailing: Column(
                      children: [
                        const Icon(Icons.more_horiz, color: Colors.red),
                        const SizedBox(height: 4),
                        Text(
                          getTimeAgo(notificationTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      notiData.reference.update({'isRead': true});
                    },
                  ),
                  const Divider(
                    thickness: 0.5,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
