import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      // The `GoogleAuthProvider` can only be used while running on the web
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final UserCredential userCredential =
            await _auth.signInWithPopup(authProvider);

        return userCredential.user;
      } catch (e) {
        debugPrint('error on web signin: $e');
        rethrow;
      }
    } else {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleSignInAuthentication =
          googleSignInAccount.authentication;

      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
              idToken: googleSignInAuthentication.idToken,
              accessToken: googleSignInAuthentication.idToken)
          as GoogleAuthCredential;

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User user = userCredential.user!;

      final User currentUser = _auth.currentUser!;
      assert(currentUser.uid == user.uid);
      debugPrint(currentUser.displayName);
      return user;
    }
  }

  static Future<void> signOutGoogle() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
