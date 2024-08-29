import 'package:flutter/material.dart';
import 'package:tr_guide/core/providers/user_provider.dart';
import 'package:tr_guide/models/post.dart';
import 'package:tr_guide/presentation/widgets/like_animation.dart';
import 'package:provider/provider.dart';
import 'package:tr_guide/services/firestore_methods.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            GestureDetector(
              onDoubleTap: () async {
                await FirestoreMethods().likePost(
                  widget.post.postId,
                  user!.uid,
                  widget.post.likes,
                );
                setState(() {
                  isLikeAnimating = true;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    widget.post.postPhotoUrl,
                    height: 360,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  AnimatedOpacity(
                    opacity: isLikeAnimating ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ],
              ),
            ),
            // Three dots menu for post owner
            if (widget.post.uid ==
                user!.uid) // Show only if the post belongs to the user
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shrinkWrap: true,
                          children: [
                            InkWell(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: const Text('Delete'),
                              ),
                              onTap: () async {
                                await FirestoreMethods()
                                    .deletePost(widget.post.postId);
                                Navigator.of(context).pop(); // Close the dialog
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(18),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.post.photoUrl),
                      radius: 36,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.location,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd.MM.yyyy')
                                .format(widget.post.datePublished),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.post.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        LikeAnimation(
                          isAnimating: widget.post.likes.contains(user.uid),
                          smallLike: true,
                          child: Row(
                            children: [
                              IconButton(
                                icon: widget.post.likes.contains(user.uid)
                                    ? const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      )
                                    : const Icon(
                                        Icons.favorite_border,
                                        color: Colors.white,
                                      ),
                                iconSize: 23,
                                onPressed: () async {
                                  await FirestoreMethods().likePost(
                                    widget.post.postId,
                                    user.uid,
                                    widget.post.likes,
                                  );
                                  setState(() {
                                    isLikeAnimating = true;
                                  });
                                },
                              ),
                              Text(
                                '${widget.post.likes.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          iconSize: 22,
                          onPressed: () {
                            // share functionality
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
