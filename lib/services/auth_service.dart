import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tr_guide/models/user.dart' as model;
import 'package:tr_guide/services/storage_methods.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final StorageMethods _storageMethods = StorageMethods();

  // get user details
  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  // logging in with Google
  Future<String> signInWithGoogle() async {
    String res = "Some error occurred";
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // Check if user already exists in Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        if (!userDoc.exists) {
          // If user doesn't exist, create a new user
          String photoUrl = googleUser.photoUrl ?? '';
          if (photoUrl.isNotEmpty) {
            // Upload the photo URL to Firebase Storage
            photoUrl = await _storageMethods.uploadImageFromUrl(
                'profilePics', photoUrl);
          }

          model.User user = model.User(
            name: googleUser.displayName ?? '',
            uid: userCredential.user!.uid,
            photoUrl: photoUrl,
            email: googleUser.email,
            followers: [],
            following: [],
          );

          // adding user in our database
          await _firestore.collection('users').doc(user.uid).set(user.toJson());
        }

        res = "success";
      } else {
        res = "Google sign in aborted";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print("Error during sign out: $e");
    }
  }
}
