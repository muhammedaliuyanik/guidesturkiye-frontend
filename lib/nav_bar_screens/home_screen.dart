import 'package:flutter/material.dart';
import 'package:tr_guide/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  void _signOut() async {
    await _authService.signOut();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('LOGGED IN'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _signOut,
        child: const Icon(Icons.logout),
      ),
    );
  }
}
