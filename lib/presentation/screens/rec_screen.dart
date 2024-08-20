import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RecScreen extends StatefulWidget {
  const RecScreen({super.key});

  @override
  State<RecScreen> createState() => _RecScreenState();
}

class _RecScreenState extends State<RecScreen> {
  String selectedCity = 'Kayseri';
  final List<String> cities = ['Kayseri', 'Istanbul', 'Ankara', 'Izmir'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Which city do you travel?",
          style: TextStyle(color: Colors.brown, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Lottie.asset(
                'assets/animations/Animation - 1724154553547.json', // Replace with your actual Lottie file path
                height: 200,
              ),
              const SizedBox(height: 20),
              const Text(
                "Please select the city you plan to visit before we suggest locations. Based on your selection, we will recommend places in that city.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 18),
              ),
              const SizedBox(height: 20),
              // Dropdown Button
              Container(
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
                  value: selectedCity,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCity = newValue!;
                    });
                  },
                  items: cities.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
              // Action Button
              ElevatedButton(
                onPressed: () {
                  // Add your action here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  "Let's get Personal",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
