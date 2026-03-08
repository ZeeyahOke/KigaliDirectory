import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider that wraps [AuthService] and exposes authentication state to the UI.
///
/// Manages: current user, loading states, error messages, email verification,
/// and Firestore user profile data.
///
/// UI widgets should NEVER call Firebase Auth directly — they interact
/// exclusively through this provider.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // ── State fields ──────────────────────────────────────────────────────────
  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────────────
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  // ── Constructor ───────────────────────────────────────────────────────────
  AuthProvider() {
    // Listen to Firebase auth state changes and update local state
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Called whenever Firebase auth state changes (login / logout / token refresh).
  void _onAuthStateChanged(User? firebaseUser) {
    _user = firebaseUser;
    if (firebaseUser != null) {
      _loadUserProfile(firebaseUser.uid);
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  /// Loads the Firestore user profile document for the given [uid].
  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _authService.getUserProfile(uid);
      if (doc.exists) {
        _userProfile = UserModel.fromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIGN UP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Registers a new user account with email, password, and display name.
  ///
  /// Sets [isLoading] to true during the operation and populates
  /// [errorMessage] on failure.
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
  _setError(_authService.getAuthErrorMessage(e.code ?? 'unknown')); 
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIGN IN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Signs in an existing user with email and password.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signIn(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setError(_authService.getAuthErrorMessage(e.code ?? 'unknown'));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Signs out the current user and clears local state.
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _userProfile = null;
      _setLoading(false);
    } catch (e) {
      _setError('Error signing out. Please try again.');
      _setLoading(false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMAIL VERIFICATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Resends the email verification link.
  Future<bool> resendVerificationEmail() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendEmailVerification();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send verification email. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  /// Reloads the user profile from Firebase and checks if email is verified.
  Future<bool> checkEmailVerification() async {
    _setLoading(true);
    try {
      final verified = await _authService.reloadAndCheckVerification();
      _user = _authService.currentUser;
      _setLoading(false);
      notifyListeners();
      return verified;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PASSWORD RESET
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sends a password reset email.
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } on FirebaseException catch (e) {
      _setError(_authService.getAuthErrorMessage(e.code ?? 'unknown'));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to send reset email. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clears any existing error message (useful when navigating away).
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
