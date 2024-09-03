import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tr_guide/presentation/widgets/recommendation_tab.dart';
import 'package:tr_guide/utils/colors.dart';
import 'package:tr_guide/core/providers/user_provider.dart';

class ResScreenPt3 extends StatefulWidget {
  final List<String> selectedPlaceIds;

  const ResScreenPt3({super.key, required this.selectedPlaceIds});

  @override
  State<ResScreenPt3> createState() => _ResScreenPt3State();
}

class _ResScreenPt3State extends State<ResScreenPt3>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _recommendations;
  List<Map<String, dynamic>> selectedRecommendations = [];
  bool _isAdded = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _recommendations = _fetchRecommendations();
  }

  Future<List<dynamic>> _fetchRecommendations() async {
    final url = 'http://52.59.198.77:5000/getRecommendation';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"liked_location_ids": widget.selectedPlaceIds}),
    );

    if (response.statusCode == 200) {
      String responseBody = response.body.replaceAll('NaN', 'null');
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to load recommendations');
    }
  }
  //????????????????????????????????????????????
  Future<void> addNotification(String uid, String type, String postId,
      String name, String userProfileImg) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(uid)
        .collection('userNotifications')
        .add({
      'type': type,
      'postId': postId,
      'name': name,
      'userProfileImg': userProfileImg,
      'datePublished': Timestamp.now(),
      'isRead': false,
    });
  }


  void _addTravelPlanToProfile() async {
    final user = Provider.of<UserProvider>(context, listen: false).getUser;

    if (selectedRecommendations.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No recommendations selected")),
        );
      }
      return;
    }

    try {
      final travelPlanRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('travelPlans')
          .doc();

      await travelPlanRef.set({
        'selectedPlaces': selectedRecommendations,
        'createdAt': Timestamp.now(),
      });


      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      var name = userSnap['name'];
      var userProfileImg = userSnap['photoUrl'];


      await addNotification(
        user.uid,
        'travel_plan',
        '',
        name,
        userProfileImg,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Travel Plan added successfully")),
        );

        setState(() {
          _isAdded =
              true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add Travel Plan")),
        );
      }
    }
  }


  void _goToHomepage() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Recommendation',
            style: TextStyle(color: redColor, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: redColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // const SizedBox(height: 15),
          Stack(
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/png/arkaplan.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: 80,
                alignment: Alignment.center,
                child: const Text(
                  "Check out your personalized recommendation results.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 89, 78, 55),
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          CustomSlidingSegmentedControl<int>(
            initialValue: _selectedIndex,
            children: const {
              0: Text('Recommendations', style: TextStyle(color: Colors.black)),
              1: Text('    Top Rated    ',
                  style: TextStyle(color: Colors.black)),
            },
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color.fromARGB(160, 158, 158, 158), width: 2),
            ),
            thumbDecoration: BoxDecoration(
              color: Colors.grey[200],
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
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                buildRecommendationsTab(),
                buildTopRatedTab(),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isAdded ? _goToHomepage : _addTravelPlanToProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right:10),
              child: Text(
                _isAdded ? 'Go Homepage' : 'Add My Travel Plan',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget buildRecommendationsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _recommendations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recommendations available.'));
        }

        final recommendations = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 13,
              mainAxisSpacing: 13,
              childAspectRatio: 2 / 3,
            ),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final place = recommendations[index];
              return buildLocationCard(
                place['location_name'] ?? 'Unknown',
                place['city'] ?? 'Unknown',
                'http://52.59.198.77:5000/images/${place['place_id']}',
                place,
              );
            },
          ),
        );
      },
    );
  }
  // Widget buildTopRatedTab(){

  // }

  //top rated
  Widget buildTopRatedTab() {
    return FutureBuilder<List<dynamic>>(
      future: _recommendations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No recommendations available.'));
        }

        final recommendations = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 13,
              mainAxisSpacing: 13,
              childAspectRatio: 2 / 3,
            ),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final place = recommendations[index];
              return buildLocationCard(
                place['location_name'] ?? 'Unknown',
                place['city'] ?? 'Unknown',
                'http://52.59.198.77:5000/images/${place['place_id']}',
                place,
              );
            },
          ),
        );
      },
    );
  }

  Widget buildLocationCard(
      String title, String city, String imageUrl, Map<String, dynamic> place) {
    final isSelected = selectedRecommendations.contains(place);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedRecommendations.remove(place);
          } else {
            selectedRecommendations.add(place);
          }
        });
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      // Shadow(
                      //   blurRadius: 10.0,
                      //   color: Colors.black,
                      //   offset: Offset(2.0, 2.0),
                      // ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [
                          // Shadow(
                          //   blurRadius: 10.0,
                          //   color: Colors.black,
                          //   offset: Offset(2.0, 2.0),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
