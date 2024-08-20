import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:tr_guide/core/providers/notification_provider.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:tr_guide/core/providers/theme_provider.dart';
import 'package:tr_guide/core/providers/user_provider.dart';
import 'package:tr_guide/presentation/onboarding/onboarding_view.dart';
import 'package:tr_guide/presentation/screens/auth_page.dart';
import 'package:tr_guide/core/firebase_options/firebase_options.dart';
import 'package:tr_guide/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  //final prefs = await SharedPreferences.getInstance();
  //final onboarding = prefs.getBool("onboarding") ?? false;

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Future.delayed(const Duration(seconds: 2)); //cok mu uzun oldu

  FlutterNativeSplash.remove();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //runApp(MyApp(onboarding: onboarding));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  const MyApp({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UnreadNotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'GuidesTurkiye',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: redColor),
              useMaterial3: true,
            ),
            //home: const AuthPage(),
            home: onboarding ? const AuthPage() : const OnboardingView(),
          );
        },
      ),
    );
  }
}
