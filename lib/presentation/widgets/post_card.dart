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
      padding: const EdgeInsets.all(8.0),
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
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  //
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
            // text and buttons on the bottom of the image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // usre  profile picture
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.post.photoUrl),
                      radius: 35,
                    ),
                    const SizedBox(width: 12),
                    // location date username
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.location,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat('dd.MM.yyyy')
                                .format(widget.post.datePublished),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.post.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // like and share bttns
                    Row(
                      children: [
                        LikeAnimation(
                          isAnimating: widget.post.likes.contains(user?.uid),
                          smallLike: true,
                          child: IconButton(
                            icon: widget.post.likes.contains(user?.uid)
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  )
                                : const Icon(
                                    Icons.favorite_border,
                                    color: Colors.white,
                                  ),
                            onPressed: () async {
                              await FirestoreMethods().likePost(
                                widget.post.postId,
                                user!.uid,
                                widget.post.likes,
                              );
                              setState(() {
                                isLikeAnimating = true;
                              });
                            },
                          ),
                        ),
                        Text(
                          '${widget.post.likes.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // paylas
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
