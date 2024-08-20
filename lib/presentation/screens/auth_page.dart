import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tr_guide/presentation/layout/mobile_screen_layout.dart';
import 'package:tr_guide/presentation/screens/login_screen.dart';
import 'package:tr_guide/presentation/screens/profile_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            //
            return MobileScreenLayout();
          } else {
            //
            return LoginPage();
          }
        },
      ),
    );
  }
}
