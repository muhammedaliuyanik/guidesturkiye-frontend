import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tr_guide/mobile_screen_layout.dart';
import 'package:tr_guide/nav_bar_screens/home_screen.dart';
import 'package:tr_guide/other_screens/login_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              //kullanıcı girs yaptıysa

              if (snapshot.hasData) {
                return const MobileScreenLayout();
              } else {
                return const LoginPage();
                //yapmadıysa
              }
            }));
  }
}
