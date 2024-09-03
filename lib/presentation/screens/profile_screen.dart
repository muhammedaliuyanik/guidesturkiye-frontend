import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tr_guide/core/providers/user_provider.dart';
import 'package:tr_guide/models/post.dart';
import 'package:tr_guide/presentation/widgets/profile_widgets/my_photos_tab.dart';
import 'package:tr_guide/presentation/widgets/profile_widgets/travel_tab.dart';
import 'package:tr_guide/presentation/widgets/profile_widgets/visited_tab.dart';
import 'package:tr_guide/utils/colors.dart';
import 'package:tr_guide/utils/utils.dart';
import 'package:tr_guide/services/firestore_methods.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool isLoading = false;
  var userData = {};
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  int _selectedIndex = 0;
  int postCount = 0;
  late final TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
    _fetchPostCount();
    getData();
  }

  void _fetchPostCount() async {
    final user = Provider.of<UserProvider>(context, listen: false).getUser;
    final postService = PostService();
    final count = await postService.getUserPostCount(user!.uid);
    setState(() {
      postCount = count;
    });
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

      if (userSnap.exists) {
        setState(() {
          userData = userSnap.data()!;
          followers = userData['followers'].length;
          following = userData['following'].length;
          isFollowing = userData['followers']
              .contains(FirebaseAuth.instance.currentUser!.uid);
        });
      }
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
    final isMyProfile = FirebaseAuth.instance.currentUser!.uid == widget.uid;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 22, right: 22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              userData['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              userData['email'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: profileColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 30),
                            if (!isMyProfile) // sadce baska kullanıcılara goster
                              ElevatedButton(
                                onPressed: () async {
                                  await FirestoreMethods().followUser(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    widget.uid,
                                  );
                                  setState(() {
                                    isFollowing = !isFollowing;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isFollowing ? Colors.grey : redColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  isFollowing ? 'Unfollow' : 'Follow',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 25, 102, 165),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(userData['photoUrl'] ?? ''),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Wrap the statistics and TabBar inside a Column
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('Following', following.toString()),
                        _buildStatColumn('Posts', postCount.toString()),
                        _buildStatColumn('Followers', followers.toString()),
                      ],
                    ),
                    const SizedBox(height: 25),
                    TabBar(
                      labelColor: redColor,
                      // dividerColor: redColor,
                      indicatorColor: redColor,
                      controller: tabController,
                      tabs: <Widget>[
                        const Tab(
                          text: 'My Photos',
                        ),
                        const Tab(text: 'Visited Places'),
                        if (isMyProfile)
                          const Tab(
                            text: 'Travel Plan',
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: <Widget>[
                      MyPhotosTab(uid: widget.uid),
                      VisitedPlacesTab(uid: widget.uid),
                      if (isMyProfile) TravelPlanTab(uid: widget.uid),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Column _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: profileColor,
          ),
        ),
      ],
    );
  }
}
