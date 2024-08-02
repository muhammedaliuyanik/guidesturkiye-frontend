import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:tr_guide/utils/utils.dart';

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
  int _selectedIndex = 0;

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
  void dispose() {
    super.dispose();
    // Kullanıcı verilerini sıfırla
    userData = {};
    postLen = 0;
    followers = 0;
    following = 0;
    isFollowing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            userData['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userData['email'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 60),
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          postLen.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Posts'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          followers.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Followers'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          following.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Following'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomSlidingSegmentedControl<int>(
                  initialValue: _selectedIndex,
                  children: const {
                    0: Text('My Photos'),
                    1: Text('Visited Places'),
                    2: Text('Travel Plan'),
                  },
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  thumbDecoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  onValueChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: const [
                      Center(child: Text('My Photos')),
                      Center(child: Text('Visited Places')),
                      Center(child: Text('Travel Plan')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
