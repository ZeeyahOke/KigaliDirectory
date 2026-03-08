import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

/// Service layer handling all Firebase Authentication operations.
///
/// No UI code should call Firebase Auth directly — all interactions go through
/// this service, which is consumed by [AuthProvider].
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the currently signed-in [User], or null if signed out.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (sign-in / sign-out events).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs up a new user with [email] and [password], creates a Firestore
  /// profile document, and sends an email verification link.
  ///
  /// Returns the created [UserCredential].
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Create the Firebase Auth account
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update the display name on the auth profile
    await credential.user?.updateDisplayName(displayName.trim());

    // Create the corresponding Firestore user profile
    if (credential.user != null) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'email': email.trim(),
        'displayName': displayName.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send email verification
      await credential.user!.sendEmailVerification();
    }

    return credential;
  }

  /// Signs in an existing user with [email] and [password].
  ///
  /// Returns the [UserCredential].
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a new email verification link to the current user.
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Reloads the current user's data from Firebase to pick up verification
  /// status changes. Returns `true` if the email is now verified.
  Future<bool> reloadAndCheckVerification() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Retrieves the Firestore user profile document for [uid].
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
  }

  /// Converts a [FirebaseAuthException] code into a user-friendly message.
  String getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
