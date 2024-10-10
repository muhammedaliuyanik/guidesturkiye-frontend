import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tr_guide/presentation/screens/location_detail.dart';

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
          return const Center(child: Text("No photos found"));
        }

        var userPosts = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1, //kare
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: userPosts.length,
            itemBuilder: (context, index) {
              var post = userPosts[index].data() as Map<String, dynamic>;
              var imageUrl =
                  post['postPhotoUrl'] ?? 'assets/images/placeholder.png';

              return GestureDetector(
                onTap: () {
                  // Navigate to the full post view or location details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationDetailsPage(
                        place: post,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
