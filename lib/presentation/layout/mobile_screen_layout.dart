import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:tr_guide/core/providers/notification_provider.dart';
import 'package:tr_guide/core/providers/user_provider.dart';
import 'package:tr_guide/presentation/screens/add_post_screen.dart';
import 'package:tr_guide/presentation/screens/settings_screen.dart';
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
    addData();
    addIsReadToExistingNotifications();
  }

  void onPageChanged(int page) {
    setState(() {
      _selectedIndex = page;
    });
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  addData() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();

    final user = userProvider.getUser;
    Provider.of<UnreadNotificationProvider>(context, listen: false)
        .fetchUnreadCount(user!.uid);
  }

  void addIsReadToExistingNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        document.reference
            .collection('userNotifications')
            .get()
            .then((subCollection) {
          subCollection.docs.forEach((doc) {
            doc.reference.update({'isRead': false});
          });
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotificationProvider =
        Provider.of<UnreadNotificationProvider>(context);
    // based on the seleceted indx
    String appBarTitle = 'GuidesTurkiye';
    if (_selectedIndex == 1) {
      appBarTitle = 'Recommendation';
    }
    if (_selectedIndex == 2) {
      appBarTitle = 'Notifications';
    }
    if (_selectedIndex == 3) {
      appBarTitle = 'Profile';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Center(
          child: Text(
            appBarTitle,
            style: const TextStyle(
              color: redColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          if (_selectedIndex == 3)
            IconButton(
                icon: Image.asset(
                  'assets/icons/settings_icon.png',
                  height: 23,
                  color: redColor,
                ),
                onPressed: (
                        // Show settings screen
                        ) =>
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    )),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: FloatingActionButton(
          backgroundColor: redColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddPostScreen(),
              ),
            );
          },
          tooltip: 'Add Post',
          child: IconButton(
            icon: Image.asset(
              'assets/icons/plus_icon.png',
              height: 23,
              color: Colors.white,
            ),
            onPressed: null,
          )),
      bottomNavigationBar: BottomAppBar(
        height: 70,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Image.asset(
                'assets/icons/home_icon.png',
                height: 27,
                color: _selectedIndex == 0 ? redColor : secondaryColor,
              ),
              onPressed: () => navigationTapped(0),
            ),
            IconButton(
              icon: Image.asset(
                'assets/icons/marker_icon.png',
                height: 25,
                color: _selectedIndex == 1 ? redColor : secondaryColor,
              ),
              onPressed: () => navigationTapped(1),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Stack(
                children: [
                  Image.asset(
                    'assets/icons/bell_icon.png',
                    height: 23,
                    color: _selectedIndex == 2 ? redColor : secondaryColor,
                  ),
                  if (unreadNotificationProvider.unreadCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${unreadNotificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => navigationTapped(2),
            ),
            IconButton(
              icon: Image.asset(
                'assets/icons/user_icon.png',
                height: 23,
                color: _selectedIndex == 3 ? redColor : secondaryColor,
              ),
              onPressed: () => navigationTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}
