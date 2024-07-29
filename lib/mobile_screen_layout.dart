import 'package:flutter/material.dart';
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
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: (){},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () => navigationTapped(0),
              color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => navigationTapped(1),
              color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () => navigationTapped(2),
              color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
            ),
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () => navigationTapped(3),
              color: _selectedIndex == 3 ? Colors.blue : Colors.grey,
            ),

          ]
        ),
      ),
    );
  }
}
