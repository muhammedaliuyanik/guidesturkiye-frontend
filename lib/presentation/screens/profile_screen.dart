import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tr_guide/core/providers/user_provider.dart';
import 'package:tr_guide/models/post.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int postCount = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPostCount();
  }

  void _fetchPostCount() async {
    final user = Provider.of<UserProvider>(context, listen: false).getUser;
    final postService = PostService();
    final count = await postService.getUserPostCount(user!.uid);
    setState(() {
      postCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          // User Profile Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                //blue border
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: Colors.blue, 
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user!.photoUrl),
                  ),
                ),
                const SizedBox(width: 20),
                // name email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          //following posts followers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Following', user.following.length.toString()),
              _buildStatColumn('Posts', postCount.toString()),
              _buildStatColumn('Followers', user.followers.length.toString()),
            ],
          ),
          const SizedBox(height: 20),
          // sliding segmented control package
          CustomSlidingSegmentedControl<int>(
            initialValue: _selectedIndex,
            children: const {
              0: Text('My Photos'),
              1: Text('Visited Places'),
              2: Text('Travel Plan'),
            },
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            thumbDecoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            onValueChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          const SizedBox(height: 20),
          // Content Section
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                MyPhotosTab(
                  uid: 'user.uid',
                ),
                Center(child: Text('Visited Places')),
                Center(child: Text('Travel Plan')),
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
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class MyPhotosTab extends StatelessWidget {
  final String uid;

  const MyPhotosTab({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No posts found"));
        }

        print(
            'Data fetched: ${snapshot.data!.docs.length} documents found'); // Debugging line

        var posts = snapshot.data!.docs;

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index].data() as Map<String, dynamic>;
            print('Post data: $post');
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(post['postPhotoUrl']),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          },
        );
      },
    );
  }
}
