import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tr_guide/utils/utils.dart';
import 'package:tr_guide/services/firestore_methods.dart';


class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
  setState(() {
    isLoading = true;
  });
  try {
    var userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    var postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.uid)
        .get();

    setState(() {
      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
    });
  } catch (e) {
    showSnackBar(
      context,
      e.toString(),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userData['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2), // Border width
                          decoration: BoxDecoration(
                            color: Colors.white, // Border color
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue, // Border color
                              width: 2, // Border width
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: userData['photoUrl'] != null
                                ? NetworkImage(userData['photoUrl'])
                                : null,
                            radius: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }

}
