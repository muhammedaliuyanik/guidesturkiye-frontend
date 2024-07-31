import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tr_guide/nav_bar_screens/home_screen.dart';
import 'package:tr_guide/nav_bar_screens/rec_screen.dart';
import 'package:tr_guide/nav_bar_screens/notification_screen.dart';
import 'package:tr_guide/nav_bar_screens/profile_screen.dart';

List<Widget> homeScreenItems = [
  const HomeScreen(),
  const RecScreen(),
  const NotificationScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
