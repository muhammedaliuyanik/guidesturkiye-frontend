import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tr_guide/presentation/screens/home_screen.dart';
import 'package:tr_guide/presentation/screens/rec_screen.dart';
import 'package:tr_guide/presentation/screens/notification_screen.dart';
import 'package:tr_guide/presentation/screens/profile_screen.dart';

List<Widget> get homeScreenItems {
  return [
    const HomeScreen(),
    const RecScreen(),
    const NotificationScreen(),
    ProfileScreen(
      uid: FirebaseAuth.instance.currentUser!.uid,
    ),
  ];
}
