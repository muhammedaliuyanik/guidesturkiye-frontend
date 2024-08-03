import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:tr_guide/presentation/screens/add_post_screen.dart';
import 'package:tr_guide/utils/colors.dart';
import 'package:tr_guide/utils/pages.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _selectedIndex = page;
    });
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Center(child: Text(
          style: TextStyle(
            color: redColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          'GuidesTurkiye')),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: redColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddPostScreen(),
          );
        },
        tooltip: 'Increment',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 70,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
            icon: const LineIcon.home(
              size: 30,
            ),
            onPressed: () => navigationTapped(0),
            color: _selectedIndex == 0 ? redColor : secondaryColor,
          ),
          IconButton(
            icon: const LineIcon.mapMarker(
              size: 30,
            ),
            onPressed: () => navigationTapped(1),
            color: _selectedIndex == 1 ? redColor : secondaryColor,
          ),
          const SizedBox(
            width: 10,
          ),
          IconButton(
            icon: const LineIcon.bell(
              size: 30,
            ),
            onPressed: () => navigationTapped(2),
            color: _selectedIndex == 2 ? redColor : secondaryColor,
          ),
          IconButton(
            icon: const LineIcon.user(
              size: 30,
            ),
            onPressed: () => navigationTapped(3),
            color: _selectedIndex == 3 ? redColor : secondaryColor,
          ),
        ]),
      ),
    );
  }
}
