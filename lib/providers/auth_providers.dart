import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import 'service_providers.dart';

/// The Firebase user for the current session, or null when logged out.
/// The AuthGate watches this to decide which screen to show.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).userChanges();
});

/// The logged-in user's Firestore profile, including their role.
final currentUserProfileProvider = StreamProvider<AppUser?>((ref) {
  // select() means this only rebuilds when the user id changes,
  // not on every small update to the Firebase user.
  final uid = ref.watch(authStateProvider.select((auth) => auth.value?.uid));
  if (uid == null) return Stream.value(null);
  return ref.watch(userServiceProvider).watchUser(uid);
});

/// Runs login, register and logout, and tracks loading and errors so the
/// screens can show a spinner or an error message.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> login({required String email, required String password}) {
    return _run(() async {
      final user = await ref
          .read(authServiceProvider)
          .login(email: email, password: password);
      // Makes sure older accounts also have a profile document.
      await ref.read(userServiceProvider).ensureProfile(
            uid: user.uid,
            email: user.email ?? email.trim(),
            name: user.displayName ?? email.split('@').first,
          );
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() async {
      final authService = ref.read(authServiceProvider);
      final user = await authService.register(
        name: name,
        email: email,
        password: password,
      );
      await ref.read(userServiceProvider).ensureProfile(
            uid: user.uid,
            email: user.email ?? email.trim(),
            name: name.trim(),
          );
      await authService.sendEmailVerification();
    });
  }

  Future<bool> resendVerificationEmail() =>
      _run(() => ref.read(authServiceProvider).sendEmailVerification());

  Future<bool> sendPasswordReset(String email) =>
      _run(() => ref.read(authServiceProvider).sendPasswordReset(email));

  /// Creates a missing profile for the user who is already logged in.
  Future<bool> repairProfile() {
    return _run(() async {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;
      await ref.read(userServiceProvider).ensureProfile(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? (user.email ?? '').split('@').first,
          );
    });
  }

  /// Checks quietly (no loading spinner) whether the email is now verified.
  Future<bool> checkEmailVerified() async {
    try {
      final verified = await ref.read(authServiceProvider).reloadAndCheckVerified();
      // Re-reads the user so the AuthGate sees emailVerified = true.
      if (verified) ref.invalidate(authStateProvider);
      return verified;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AsyncData(null);
  }

  /// Sets loading, runs the action, then stores either success or the error.
  /// Returns true when it worked.
  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
