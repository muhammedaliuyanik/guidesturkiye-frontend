import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'res_screen_pt3.dart';
import 'package:tr_guide/utils/colors.dart';
import 'loading_screen.dart'; // Import the LoadingScreen widget

class RecScreenPt2 extends StatefulWidget {
  final String currentCity;

  const RecScreenPt2({super.key, required this.currentCity});

  @override
  State<RecScreenPt2> createState() => _RecScreenPt2State();
}

class _RecScreenPt2State extends State<RecScreenPt2> {
  late Future<List<dynamic>> _locations;
  List<String> selectedPlaceIds = [];

  @override
  void initState() {
    super.initState();
    _locations = _fetchLocations();
  }

  Future<List<dynamic>> _fetchLocations() async {
    final url =
        'http://52.59.198.77:5000/getLocations?current_city=${widget.currentCity}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String jsonString = response.body.replaceAll('NaN', 'null');
      final List<dynamic> data = json.decode(jsonString);
      return data;
    } else {
      throw Exception('Failed to load locations');
    }
  }

  void _handleSeeRecommendations() async {
    if (selectedPlaceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one location.'),
        ),
      );
      return;
    } else if (selectedPlaceIds.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 3 locations.'),
        ),
      );
      return;
    }

    //ucak sayfa
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadingScreen()),
    );

    //delay
    await Future.delayed(const Duration(seconds: 3));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResScreenPt3(
          selectedPlaceIds: selectedPlaceIds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Recommendation',
          style: TextStyle(color: redColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: redColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
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
                  "Please select at least 5 locations to get recommendations.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 89, 78, 55),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _locations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No locations available.'));
                }

                final locations = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 3,
                      crossAxisSpacing: 13,
                      mainAxisSpacing: 13,
                    ),
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final place = locations[index];
                      final placeName = place['location_name'] ?? 'Unknown';
                      final placeId = place['place_id'] ?? '';
                      final imageUrl = placeId.isNotEmpty
                          ? 'http://52.59.198.77:5000/images/$placeId'
                          : 'assets/images/placeholder.png';

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            place['selected'] = !(place['selected'] ?? false);
                            if (place['selected'] == true) {
                              selectedPlaceIds.add(placeId);
                            } else {
                              selectedPlaceIds.remove(placeId);
                            }
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: placeId.isNotEmpty
                                      ? NetworkImage(imageUrl)
                                      : AssetImage(imageUrl) as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (place['selected'] == true)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black
                                      .withOpacity(0.5), // Add shadow overlay
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 50, // Adjust size as needed
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
                                    placeName,
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
                                        '•', // Dot before the city name
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                          width:
                                              4), // Space between dot and city name
                                      Text(
                                        widget.currentCity,
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
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleSeeRecommendations,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "See Recommendations",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
