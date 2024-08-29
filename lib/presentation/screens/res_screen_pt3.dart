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
          .doc(); // Automatically generates a unique ID for the document

      await travelPlanRef.set({
        'selectedPlaces': selectedRecommendations,
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Travel Plan added successfully")),
        );

        setState(() {
          _isAdded =
              true; // Change the button state to indicate it has been clicked
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
              0: Text('Recommendations'),
              1: Text('    Top Rated    '),
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
          const SizedBox(height: 16),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children:  [
                buildRecommendationsTab(),
                Center(child: Text('Top Rated')),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isAdded ? _goToHomepage : _addTravelPlanToProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: redColor,
            padding: const EdgeInsets.symmetric(vertical: 17),
          ),
          child: Text(
            _isAdded ? 'Go Homepage' : 'Add My Travel Plan',
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
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
      child: Card(
        elevation: isSelected ? 6 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  if (isSelected)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(city, style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
