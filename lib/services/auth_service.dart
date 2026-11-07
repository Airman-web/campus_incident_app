import 'package:firebase_auth/firebase_auth.dart';

import '../utils/app_exception.dart';
import '../utils/validators.dart';

/// All Firebase Authentication calls live here.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  /// Emits the signed-in user (or null) every time the session changes.
  Stream<User?> userChanges() => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _requireAluEmail(email);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await user.updateDisplayName(name.trim());
      return user;
    } on FirebaseAuthException catch (e) {
      throw AppException(_messageFor(e));
    }
  }

  Future<User> login({required String email, required String password}) async {
    _requireAluEmail(email);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AppException(_messageFor(e));
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw const AppException('You are not logged in.');
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AppException(_messageFor(e));
    }
  }

  /// Asks Firebase for the latest user data. If the email is now verified,
  /// it also refreshes the login token so the security rules see the change.
  Future<bool> reloadAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final refreshed = _auth.currentUser;
    if (refreshed != null && refreshed.emailVerified) {
      await refreshed.getIdToken(true);
      return true;
    }
    return false;
  }

  Future<void> sendPasswordReset(String email) async {
    _requireAluEmail(email);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AppException(_messageFor(e));
    }
  }

  Future<void> logout() => _auth.signOut();

  void _requireAluEmail(String email) {
    if (!Validators.isAluEmail(email)) {
      throw const AppException('Please use your ALU email address.');
    }
  }

  String _messageFor(FirebaseAuthException e) {
    return switch (e.code) {
      'email-already-in-use' =>
        'An account already exists for this email. Try logging in.',
      'invalid-email' => 'That email address is not valid.',
      'weak-password' => 'Choose a stronger password (at least 6 characters).',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'Email or password is incorrect.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'network-request-failed' =>
        'No internet connection. Check your network and try again.',
      _ => e.message ?? 'Authentication failed. Please try again.',
    };
  }
}
