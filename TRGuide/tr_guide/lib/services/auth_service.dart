//google sign in

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GAuthService {
  //google sgin in
  signInWithGoogle() async {
    // interactiv sign process
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    //opens the google sign in page

    //auth details from req
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    //create a new cred for user
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //sign in with cred
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
