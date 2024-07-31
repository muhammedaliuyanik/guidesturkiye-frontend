import 'package:flutter/material.dart';
import 'package:tr_guide/components/my_button.dart';
import 'package:tr_guide/components/my_square_tile.dart';
import 'package:tr_guide/components/my_textfield.dart';
import 'package:tr_guide/services/auth_service.dart';
//import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  //final void Function() onTap;

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //textcontrollers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _pwController.dispose();
  } //important bc f the when they are no longer needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                //logo
                Image.asset(
                  "assets/images/logo.png",
                  width: 100,
                ),
                const SizedBox(height: 20),
                //uyg adi
                const Text(
                  'T R G U I D E',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 25),
                //mail textfield

                const SizedBox(height: 10),
                //password textfield

                const SizedBox(height: 10),
                //forgot p

                const SizedBox(height: 10),

                const SizedBox(height: 30),

                const SizedBox(height: 30),
                //google+apple sign in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google png
                    MySquareTile(
                      imagePath: "assets/images/google.png",
                      onTap: () => AuthService().signInWithGoogle(),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    //apple png
                    MySquareTile(
                      imagePath: "assets/images/apple.png",
                      onTap: () {
                        //sign in with apple
                        //
                        //
                        //daha sonra yapicam
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                //dont you have an account? sign up here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
