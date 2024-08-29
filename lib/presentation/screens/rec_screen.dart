import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tr_guide/presentation/screens/rec_screen_pt2.dart';

class RecScreen extends StatefulWidget {
  const RecScreen({super.key});

  @override
  State<RecScreen> createState() => _RecScreenState();
}

class _RecScreenState extends State<RecScreen> {
  String currentCity = 'Kayseri';
  String destinationCity = 'Antalya';
  final List<String> cities = [
    'Kayseri',
    'Nevşehir',
    'Antalya',
    'Mersin',
    'Adana',
    'Gaziantep',
    'İspanya',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      "Which city are you in now?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromARGB(255, 89, 78, 55),
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/Animation - 1724154553547.json',
                      height: 150,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildDropdownButton("Current City", currentCity,
                          (String? newValue) {
                        setState(() {
                          currentCity = newValue!;
                        });
                      }),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Please select the city you plan to visit before we suggest locations. Based on your selection, we will recommend places in that city.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildDropdownButton(
                          "Destination City", destinationCity,
                          (String? newValue) {
                        setState(() {
                          destinationCity = newValue!;
                        });
                      }),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          final locations = await _fetchLocations(
                              currentCity, destinationCity);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecScreenPt2(
                                currentCity: currentCity,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 27),
                          child: Text(
                            "Let's get Personal",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownButton(
      String label, String selectedValue, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedValue,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
        underline: const SizedBox(),
        onChanged: onChanged,
        items: cities.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
      ),
    );
  }

  Future<List<dynamic>> _fetchLocations(
      String currentCity, String destinationCity) async {
    final url =
        'http://52.59.198.77:5000/getLocationsByCityName?current_city=$currentCity&destination_city=$destinationCity';
    final response = await http.get(Uri.parse(url));
    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data == null) {
        print("The API returned a null response.");
        return [];
      }

      if (data is Map<String, dynamic> && data.containsKey('locations')) {
        return data['locations'] as List<dynamic>;
      }

      if (data is List<dynamic>) {
        return data;
      }

      print("Unexpected response structure.");
      return [];
    } else {
      throw Exception('Failed to load locations');
    }
  }
}
