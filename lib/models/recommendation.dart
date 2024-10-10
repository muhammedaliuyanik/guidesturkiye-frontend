import 'package:cloud_firestore/cloud_firestore.dart';

class Recommendation {
  final String city;
  final String country;
  final List categories;
  final String location;
  final String uid;

  Recommendation(
      {required this.uid,
      required this.city,
      required this.country,
      required this.categories,
      required this.location});

      static Recommendation fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Recommendation(
      city: snapshot["city"] ?? '',
      country: snapshot["country"] ?? '',
      categories: snapshot["categories"] ?? [],
      location: snapshot["location"] ?? '',
      uid: snapshot["uid"] ?? '',
    );
  }




      Map<String, dynamic> toJson() => {
        "uid": uid,
        "country": country,
        "city": city,
        "categories": categories,
        "location": location,
      };
}
