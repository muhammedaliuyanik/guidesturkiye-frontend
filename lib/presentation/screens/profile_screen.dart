import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tr_guide/core/providers/user_provider.dart';
import 'package:tr_guide/models/post.dart';
import 'package:tr_guide/presentation/widgets/travel_tab.dart';
import 'package:tr_guide/utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int postCount = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPostCount();
  }

  void _fetchPostCount() async {
    final user = Provider.of<UserProvider>(context, listen: false).getUser;
    final postService = PostService();
    final count = await postService.getUserPostCount(user!.uid);
    setState(() {
      postCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          // User Profile Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Elemanları hizalamak için
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profil fotoğrafı
                    Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 60, // Profil fotoğrafı boyutunu artırdık
                        backgroundImage: NetworkImage(user!.photoUrl),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // İsim ve e-posta
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20, // Metin boyutunu küçülttük
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14, // Metin boyutunu küçülttük
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Follow / Edit Profile Button
                        ElevatedButton(
                          onPressed: () {
                            // Follow veya Edit Profile butonu işlevi
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                redColor, // Butonun arka plan rengini ayarladık
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical:
                                    10), // Daha ince ve uzun bir görünüm için padding ayarı
                            minimumSize: const Size(100,
                                40), // Butonun minimum genişlik ve yükseklik ayarları
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Köşeleri yuvarlatıyoruz
                            ),
                          ),
                          child: const Text(
                            'Follow', // Buton metni
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          //following posts followers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Following', user.following.length.toString()),
              _buildStatColumn('Posts', postCount.toString()),
              _buildStatColumn('Followers', user.followers.length.toString()),
            ],
          ),
          const SizedBox(height: 20),
          // Sliding segmented control
          CustomSlidingSegmentedControl<int>(
            initialValue: _selectedIndex,
            children: const {
              0: Text('My Photos'),
              1: Text('Visited Places'),
              2: Text('Travel Plan'),
            },
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            thumbDecoration: BoxDecoration(
              color: Colors.red,
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
          const SizedBox(height: 20),
          // possts 
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                const Center(child: Text('My Photos')),
                const Center(child: Text('Visited Places')),
                TravelPlanTab(uid: user.uid), // Seyahat planlarını göster
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
