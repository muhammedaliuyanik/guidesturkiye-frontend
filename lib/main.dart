import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tr_guide/mobile_screen_layout.dart';
import 'package:tr_guide/other_screens/auth_page.dart';
import 'package:tr_guide/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MobileScreenLayout(),
    );
  }
}

