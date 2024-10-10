import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tr_guide/presentation/screens/location_detail.dart';

class TravelPlanTab extends StatelessWidget {
  final String uid;

  const TravelPlanTab({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('travelPlans')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No travel plans found"));
        }

        var travelPlans = snapshot.data!.docs;

        // Flatten all selectedPlaces into one list
        var selectedPlaces = travelPlans
            .expand(
                (travelPlan) => travelPlan['selectedPlaces'] as List<dynamic>)
            .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: selectedPlaces.length,
            itemBuilder: (context, index) {
              var place = selectedPlaces[index];
              var placeId = place['place_id'] ?? '';
              var placeName = place['location_name'] ?? 'Unknown';
              var city = place['city'] ?? '';
              var imageUrl = placeId.isNotEmpty
                  ? 'http://52.59.198.77:5000/images/$placeId'
                  : 'assets/images/placeholder.png';

              return GestureDetector(
                onTap: () {
                  // Navigate to the Location Details Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationDetailsPage(
                        place: place,
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        image: DecorationImage(
                          image: placeId.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : AssetImage(imageUrl) as ImageProvider,
                          fit: BoxFit.cover,
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
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                city,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
    );
  }
}
