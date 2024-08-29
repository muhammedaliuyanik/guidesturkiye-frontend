import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tr_guide/core/providers/user_provider.dart';

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
      appBar: AppBar(
        title: const Text('Location Details'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        // Added ScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'http://52.59.198.77:5000/images/${widget.place['place_id']}',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            // Location Name
            Text(
              widget.place['location_name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // City and Country
            Text(
              '${widget.place['city']}, ${widget.place['country'] ?? ''}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Rating
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow[700]),
                const SizedBox(width: 4),
                Text(
                  '${widget.place['rating']} (${widget.place['comment_count']} reviews)',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // About
            const Text(
              'About',
              style:  TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.place['about'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Visited Button
            GestureDetector(
              onTap: isVisited ? null : _markAsVisited,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isVisited ? Colors.grey[300] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Visited",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.check_circle,
                      color: Colors.grey,
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
