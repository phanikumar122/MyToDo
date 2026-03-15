import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth   _auth        = FirebaseAuth.instance;
  final GoogleSignIn   _googleSignIn = GoogleSignIn();

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Sign in with Google and return the FirebaseUser.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('=== Google Sign-In Error ===');
      debugPrint(e.toString());
      if (e.toString().contains('api-ms-win-core')) {
        debugPrint('Possible system library mismatch.');
      } else if (e.toString().contains('10')) {
        debugPrint('ApiException 10: This usually means SHA-1 fingerprints or Support Email are missing in Firebase.');
      }
      rethrow;
    }
  }

  /// Get the current user's Firebase ID token (sent with every API request).
  Future<String?> getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken(true);
    } catch (_) {
      return null;
    }
  }

  /// Sign out from both Firebase and Google.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
