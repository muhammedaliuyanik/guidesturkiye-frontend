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

        return ListView.builder(
          itemCount: travelPlans.length,
          itemBuilder: (context, index) {
            var travelPlan = travelPlans[index].data() as Map<String, dynamic>;
            var selectedPlaces = travelPlan['selectedPlaces'] as List<dynamic>;

            return Card(
              margin: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: selectedPlaces.map((place) {
                  return ListTile(
                    leading: Image.network(
                      'http://52.59.198.77:5000/images/${place['place_id']}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(place['location_name']),
                    subtitle: Text(place['city']),
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
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
