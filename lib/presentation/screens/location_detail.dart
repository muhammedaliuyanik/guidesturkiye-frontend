import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tr_guide/core/providers/user_provider.dart';
import 'package:tr_guide/utils/colors.dart';

class LocationDetailsPage extends StatefulWidget {
  final Map<String, dynamic> place;

  const LocationDetailsPage({super.key, required this.place});

  @override
  _LocationDetailsPageState createState() => _LocationDetailsPageState();
}

class _LocationDetailsPageState extends State<LocationDetailsPage> {
  bool isVisited = false;

  @override
  void initState() {
    super.initState();
    _checkIfVisited();
  }

  void _checkIfVisited() async {
    final user = Provider.of<UserProvider>(context, listen: false).getUser;
    final uid = user?.uid;

    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('visitedPlaces')
          .doc(widget.place['place_id'])
          .get();

      if (doc.exists) {
        setState(() {
          isVisited = true;
        });
      }
    }
  }

  void _markAsVisited() async {
    final user = Provider.of<UserProvider>(context, listen: false).getUser;
    final uid = user?.uid;

    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('visitedPlaces')
          .doc(widget.place['place_id'])
          .set(widget.place);

      setState(() {
        isVisited = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Location Details',
          style: TextStyle(color: redColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: redColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  'http://52.59.198.77:5000/images/${widget.place['place_id']}',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
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
                      color: Colors.black.withOpacity(0.6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.place['city']} - ${widget.place['country'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.place['location_name'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Rating
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(131, 240, 240, 240),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 38.0, right: 16.0, top: 16, bottom: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow[700], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.place['rating']} Rating ${widget.place['comment_count']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(139, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About
                  const SizedBox(height: 14),
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.place['about'] ?? 'No description available.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(255, 121, 120, 120),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
            // Visited Button
            Padding(
              padding: const EdgeInsets.only(
                left: 40.0,
                right: 40.0,
              ),
              child: GestureDetector(
                onTap: isVisited ? null : _markAsVisited,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isVisited ? Colors.grey[300] : Colors.green[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isVisited
                            ? "You Visited This Place"
                            : "I Visited This Place",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: isVisited ? Colors.white : Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
